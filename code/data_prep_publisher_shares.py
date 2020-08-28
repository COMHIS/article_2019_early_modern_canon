import math
from commonlibs_py.helpers import (
    list_to_dict_by_key,
    filter_rows_with_field_value)
from commonlibs_py.data_exporters import write_dictlist_csv
from commonlibs_py.data_importers import read_csv_to_dict
from estclibs_py.data_importers import (
    read_estc_pub_years,
    read_estc_cleaned_initial)
from estclibs_py.data_prep import (
    pubyear_validates,
    add_pubyears)


def get_actor_rolecounts_for_year_range(actors, actorlinks, start_y, end_y):
    links_subset = []
    subset_actorids = set()
    for actorlink in actorlinks:
        if pubyear_validates(actorlink['pubyear']):
            if (int(actorlink['pubyear']) >= start_y and
                    int(actorlink['pubyear']) <= end_y):
                links_subset.append(actorlink)
                subset_actorids.add(actorlink['actor_id'])
    links_subset_by_actor = list_to_dict_by_key(links_subset, 'actor_id')
    #
    all_actor_counts = []
    #
    for actor in actors:
        if actor['actor_id'] in subset_actorids:
            links_for_actor = links_subset_by_actor[actor['actor_id']]
            all_curives_total = len(links_for_actor)
            publisher_total = 0
            printer_total = 0
            bookseller_total = 0
            pub_pri_total = 0
            pub_true_count = 0
            for actorlink in links_for_actor:
                if actorlink['actor_role_publisher'] == "True":
                    publisher_total += 1
                if actorlink['actor_role_bookseller'] == "True":
                    bookseller_total += 1
                if actorlink['actor_role_printer'] == "True":
                    printer_total += 1
                if (actorlink['actor_role_publisher'] == "True" or
                        actorlink['actor_role_printer'] == "True"):
                    pub_pri_total += 1
                if actorlink['primary_publisher'] == "True":
                    pub_true_count += 1
            actor_counts = {
                'actor_id': actor['actor_id'],
                'actor_gender': actor['actor_gender'],
                'link_curives_count': all_curives_total,
                'link_printer_count': printer_total,
                'link_bookseller_count': bookseller_total,
                'link_publisher_count': publisher_total,
                'link_pub_pri_count': pub_pri_total,
                'link_publisher_true_count': pub_true_count
            }
            if actor_counts['link_pub_pri_count'] > 0:
                all_actor_counts.append(actor_counts)
    #
    all_actor_counts_sorted = sorted(
        all_actor_counts,
        key=lambda k: k['link_pub_pri_count'],
        reverse=True)
    return all_actor_counts_sorted


def get_treshold_levels(
        actor_rolecount_sorted,
        treshold_levels=[1, 5, 10, 20, 40]):
    total_actors = len(actor_rolecount_sorted)
    tresholds = []
    for treshold_level in treshold_levels:
        n_actors = math.ceil(total_actors * (treshold_level / 100))
        tresholds.append({
                'percentile': treshold_level,
                'actor_count': n_actors,
                'min_pubs': actor_rolecount_sorted[
                    n_actors - 1]['link_pub_pri_count']
            })
    return tresholds


def set_actor_count_percentiles(actor_rolecount_sorted, treshold_levels):
    if len(actor_rolecount_sorted) == 0:
        return actor_rolecount_sorted
    tresholds = get_treshold_levels(
        actor_rolecount_sorted, treshold_levels)
    actor_rank = 1
    for actor in actor_rolecount_sorted:
        percentile = 100
        for treshold in tresholds:
            if actor['link_pub_pri_count'] >= treshold['min_pubs']:
                percentile = treshold['percentile']
                break
        actor.update({'rank': actor_rank,
                      'percentile': percentile})
        actor_rank += 1
    return actor_rolecount_sorted


def get_timewindows(start_y, end_y, time_window, time_step):
    resultlist = []
    current_start_y = start_y
    while (current_start_y + time_window - 1 - time_step) < end_y:
        resultlist.append({
            'slice_start': current_start_y,
            'slice_end': current_start_y + time_window - 1})
        current_start_y += time_step
    return resultlist


def add_publisher_percentile(
        estc_maindata,
        links_by_curives,
        rolecount_outlist_by_actor):
    results = []
    for item in estc_maindata:
        if not pubyear_validates(item['pubyear']):
            continue
        if item['curives'] in links_by_curives.keys():
            item_percentiles = set()
            pub_ids = set()
            for publisher in links_by_curives[item['curives']]:
                pub_ids.add(publisher['actor_id'])
            for pub_id in pub_ids:
                if pub_id in rolecount_outlist_by_actor.keys():
                    for pub_per in rolecount_outlist_by_actor[pub_id]:
                        if int(pub_per['slice_end_year']) == int(
                                item['pubyear']):
                            item_percentiles.add(pub_per['percentile'])
            if len(item_percentiles) > 0:
                item.update({'percentile': min(item_percentiles)})
                results.append(item)
    return results


def main():
    actors_csv = "../data/raw/unified_actors.csv"
    pubyears_csv = "../data/raw/publicationyears.csv"
    estc_titles_csv = (
        "../../estc-data-unified/estc-cleaned-initial/estc_processed.csv")
    actorlinks_csv = "../data/raw/unified_actorlinks_enriched.csv"

    print("Reading data ... ")
    actors = read_csv_to_dict(actors_csv)
    actors = filter_rows_with_field_value(actors, 'actor_id', 'AUTHOR')
    pubyears = read_estc_pub_years(pubyears_csv)
    actorlinks = read_csv_to_dict(actorlinks_csv)
    estc_maindata = read_estc_cleaned_initial(estc_titles_csv)
    estc_maindata = add_pubyears(estc_maindata, pubyears)

    # generate base percentile data
    timewindows = get_timewindows(1400, 1799, 10, 1)

    rolecount_list = []
    for timewindow in timewindows:
        print("actor_rolecounts, 10 year slice end: " +
              str(timewindow['slice_end']))
        actor_rolecounts = get_actor_rolecounts_for_year_range(
            actors, actorlinks,
            timewindow['slice_start'], timewindow['slice_end'])
        actor_rolecounts = set_actor_count_percentiles(
            actor_rolecounts, treshold_levels=list(range(1, 101)))
        rolecount_list.append({
            'end_y': timewindow['slice_end'],
            'actor_rankdata': actor_rolecounts})

    # percentiles for roles per year
    rolecount_outlist = []
    for item in rolecount_list:
        if len(item['actor_rankdata']) == 0:
            continue
        else:
            for actor in item['actor_rankdata']:
                rolecount_outlist.append({
                    'slice_end_year': item['end_y'],
                    'actor_id': actor['actor_id'],
                    'actor_gender': actor['actor_gender'],
                    'link_curives_count': actor['link_curives_count'],
                    'link_printer_count': actor['link_printer_count'],
                    'link_bookseller_count': actor['link_bookseller_count'],
                    'link_publisher_count': actor['link_publisher_count'],
                    'link_pub_pri_count': actor['link_pub_pri_count'],
                    'link_publisher_true_count': (
                        actor['link_publisher_true_count']),
                    'rank': actor['rank'],
                    'percentile': actor['percentile']})

    links_by_curives = list_to_dict_by_key(actorlinks, 'curives')
    rolecounts_by_actor = list_to_dict_by_key(rolecount_outlist, 'actor_id')

    # add publisher percentile data to each estc entry
    estc_pub_percentiles = add_publisher_percentile(
        estc_maindata, links_by_curives, rolecounts_by_actor)

    # save figure interim input data
    write_dictlist_csv(
        rolecount_outlist,
        "../data/work/publisher_id_10year_slices_rank_and_percentile.csv")
    write_dictlist_csv(
        estc_pub_percentiles,
        "../data/work/estc_titles_pub_percentiles.csv")


if __name__ == "__main__":
    main()
