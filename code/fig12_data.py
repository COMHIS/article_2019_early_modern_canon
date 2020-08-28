from commonlibs_py.canon_helpers import get_workid_curives_set
from commonlibs_py.helpers import (
    list_to_dict_by_key,
    filter_rows_with_field_value)
from commonlibs_py.data_exporters import write_dictlist_csv
from commonlibs_py.data_importers import read_csv_to_dict
from estclibs_py.data_importers import (
    read_estc_pub_years,
    read_estc_cleaned_initial)
from estclibs_py.data_prep import (
    get_actorlinks_with_pubyears,
    add_pubyears,
    pubyear_validates)


def mutate_actorlinks_primary_publisher(actorlinks_by_curives):
    for curives in actorlinks_by_curives.keys():
        curives_actors = actorlinks_by_curives[curives]
        has_primary_publisher = False
        for actorlink in curives_actors:
            actorlink.update({'primary_publisher': "False"})
            if actorlink['actor_role_publisher'] == "True":
                has_primary_publisher = True
                actorlink.update({'primary_publisher': "True"})
        if not has_primary_publisher:
            for actorlink in curives_actors:
                if actorlink['actor_role_printer'] == "True":
                    actorlink.update({'primary_publisher': "True"})


def get_work_primary_publishers(
        work_id, workdata_by_work_id, actorlinks_by_curives):
    # output: list of dicts. values: pub_year, curives, primary_pubs
    work_curives = get_workid_curives_set(work_id, workdata_by_work_id)
    yearly_primary_pubs = []
    for curives in work_curives:
        if curives in actorlinks_by_curives.keys():
            curives_actors = actorlinks_by_curives[curives]
            publisher_ids = []
            for actorlink in curives_actors:
                if actorlink['primary_publisher'] == "True":
                    publisher_ids.append(
                        {'actor_id': actorlink['actor_id'],
                         'status': 'unk'})
            if pubyear_validates(actorlink['pubyear']):
                yearly_primary_pubs.append(
                    {'work_id': work_id,
                     'curives': curives,
                     'pubyear': int(actorlink['pubyear']),
                     'publishers': publisher_ids})
    yearly_primary_pubs = sorted(
        yearly_primary_pubs, key=lambda k: k['pubyear'])
    return yearly_primary_pubs


def set_pubs_repeat_status(pubsdata, actors_by_id):
    all_pubyears = set()
    for item in pubsdata:
        all_pubyears.add(item['pubyear'])
    all_pubyears = list(all_pubyears)
    all_pubyears.sort()
    all_prev_pub_ids = set()
    pubsdata_by_year = list_to_dict_by_key(pubsdata, 'pubyear')
    if len(all_pubyears) > 0:
        first_pubyear = all_pubyears[0]
    else:
        first_pubyear = None
    prev_year_pubs = []
    for year in all_pubyears:
        this_year_pubs = pubsdata_by_year[year]
        for item in this_year_pubs:
            if year == first_pubyear:
                for publisher in item['publishers']:
                    publisher.update({'status': 'new_work'})
            else:
                prev_year_pub_ids = []
                for pubinstance in prev_year_pubs:
                    for pub_actor in pubinstance['publishers']:
                        prev_year_pub_ids.append(pub_actor['actor_id'])
                all_prev_pub_ids = all_prev_pub_ids.union(
                    set(prev_year_pub_ids))
                for publisher in item['publishers']:
                    if publisher['actor_id'] in prev_year_pub_ids:
                        publisher.update({'status': 'stable'})
                    elif publisher['actor_id'] in all_prev_pub_ids:
                        publisher.update(
                            {'status': 'return_of_earlier_publisher'})
                    else:
                        # if all prev publishers are inactive:
                        # set status as 'new_publisher_old_inactive'
                        all_prev_inactive = True
                        for prev_pub_id in prev_year_pub_ids:
                            actor_lastpub = actors_by_id[prev_pub_id][0][
                                    'year_pub_last_estc']
                            if pubyear_validates(actor_lastpub):
                                actor_lastpub_int = int(actor_lastpub)
                                if (actor_lastpub_int >= year):
                                    all_prev_inactive = False
                                    break
                        if all_prev_inactive:
                            publisher.update(
                                {'status': 'new_publisher_old_inactive'})
                        else:
                            publisher.update({'status': 'new_publisher'})
        prev_year_pubs = this_year_pubs


def add_publisher_names(pubsdata, actors_by_id):
    for entry in pubsdata:
        for publisher in entry['publishers']:
            pubname = actors_by_id[publisher['actor_id']][0]['name_unified']
            publisher.update({'name': pubname})


def write_work_pub_sequence_data_csv(pubsdata, outfile):
    outlist = []
    for item in pubsdata:
        for publisher in item['publishers']:
            outlist.append({
                'work_id': item['work_id'],
                'curives': item['curives'],
                'pubyear': item['pubyear'],
                'publisher_actor_id': publisher['actor_id'],
                'publisher_name': publisher['name'],
                'publisher_sequence': publisher['status']
            })
    write_dictlist_csv(outlist, outfile)


def get_work_pub_seq_year_summary(pubsdata, relative_weights=True):
    all_years = set()
    for item in pubsdata:
        all_years.add(item['pubyear'])
    all_years = list(all_years)
    all_years.sort()
    results_dict = {}
    for year in all_years:
        results_dict[year] = {
            'new_work': 0,
            'stable': 0,
            'return_of_earlier_publisher': 0,
            'new_publisher_old_inactive': 0,
            'new_publisher': 0}
    #
    for item in pubsdata:
        item_year = item['pubyear']
        for publisher in item['publishers']:
            publisher_status = publisher['status']
            if relative_weights:
                results_dict[item_year][publisher_status] += (
                    1 / len(item['publishers']))
            else:
                results_dict[item_year][publisher_status] += 1
    return results_dict


def write_pubs_seq_summary_csv(pubs_summarydata, outfile):
    outlist = []
    for key, value in pubs_summarydata.items():
        outdict = {'pubyear': key}
        outdict.update(value)
        outlist.append(outdict)
    write_dictlist_csv(outlist, outfile)


def add_actorlinks_publocs(actorlinks, estc_maindata):
    estc_maindata_by_curives = list_to_dict_by_key(estc_maindata, 'curives')
    for actorlink in actorlinks:
        curives = actorlink['curives']
        if curives in estc_maindata_by_curives.keys():
            actorlink.update({
                'publoc': estc_maindata_by_curives[curives][0]['pub_loc']})
        else:
            actorlink.update({
                'publoc': 'unk'})


def get_pub_seq_data_for_actorlinks(
        workdata_by_work_id,
        actorlinks_by_curives,
        actors_by_id):
    all_pubs = []
    for work_id in workdata_by_work_id.keys():
        pubs = get_work_primary_publishers(
            work_id, workdata_by_work_id, actorlinks_by_curives)
        set_pubs_repeat_status(pubs, actors_by_id)
        # all states:
        # 'new_work'
        # 'stable'
        # 'return_of_earlier_publisher'
        # 'new_publisher_old_inactive'
        # 'new_publisher'
        add_publisher_names(pubs, actors_by_id)
        all_pubs.append(pubs)
    combined_all_pubs = []
    for pubslist in all_pubs:
        combined_all_pubs.extend(pubslist)
    return combined_all_pubs


def get_flattened_pub_seq_data(pub_seq_data):
    outlist = []
    for item in pub_seq_data:
        for publisher in item['publishers']:
            outdict = {}
            for key, value in item.items():
                if key != 'publishers':
                    outdict.update({key: value})
            outdict.update({'publisher_actor_id': publisher['actor_id'],
                            'publisher_work_seq': publisher['status']})
            outlist.append(outdict)
    return(outlist)


def update_actorlinks_with_pubseq(actorlinks, flat_pub_seq_data):
    flat_ps_by_mergekey = {}
    for item in flat_pub_seq_data:
        mergekey = item['curives'] + "_" + item['publisher_actor_id']
        flat_ps_by_mergekey[mergekey] = item
    for actorlink in actorlinks:
        mergekey = actorlink['curives'] + "_" + actorlink['actor_id']
        if mergekey in flat_ps_by_mergekey.keys():
            mdata = flat_ps_by_mergekey[mergekey]
            actorlink.update(
                {'publisher_work_sequence': mdata['publisher_work_seq']})
        else:
            if actorlink['primary_publisher'] == "True":
                actorlink.update(
                    {'publisher_work_sequence':
                     'no_data_reason_workdata_missing'})
            else:
                actorlink.update(
                    {'publisher_work_sequence':
                     'no_data_reason_not_publisher'})


def main():
    # data setup
    actorlinks_csv = "../data/raw/unified_actorlinks_enriched.csv"
    pubyears_tsv = "../data/raw/publicationyears.csv"
    actors_csv = "../data/raw/unified_actors.csv"
    estc_titles_csv = "../data/raw/estc_processed.csv"
    work_csv = "../data/raw/estc_works_roles.csv"

    pubyears = read_estc_pub_years(pubyears_tsv)
    estc_maindata = read_estc_cleaned_initial(estc_titles_csv)
    estc_maindata = add_pubyears(estc_maindata, pubyears)

    actorlinks = read_csv_to_dict(actorlinks_csv)
    actorlinks = get_actorlinks_with_pubyears(actorlinks, pubyears)
    actorlinks = filter_rows_with_field_value(actorlinks, 'actor_id', 'AUTHOR')
    add_actorlinks_publocs(actorlinks, estc_maindata)
    actorlinks_by_curives = list_to_dict_by_key(actorlinks, 'curives')
    # add primary publisher data to actorlinks
    mutate_actorlinks_primary_publisher(actorlinks_by_curives)

    actors = read_csv_to_dict(actors_csv)
    actors = filter_rows_with_field_value(actors, 'actor_id', 'AUTHOR')
    actors_by_id = list_to_dict_by_key(actors, 'actor_id')

    workdata = read_csv_to_dict(work_csv)
    workdata_by_work_id = list_to_dict_by_key(workdata, 'finalWorkField')

    # set seqdata for relevant pubs
    pub_seq_data = get_pub_seq_data_for_actorlinks(
        workdata_by_work_id,
        actorlinks_by_curives,
        actors_by_id)
    add_actorlinks_publocs(pub_seq_data, estc_maindata)

    flat_pub_seq_data = get_flattened_pub_seq_data(pub_seq_data)
    update_actorlinks_with_pubseq(actorlinks, flat_pub_seq_data)

    # get data for figure
    pubs_summary = get_work_pub_seq_year_summary(pub_seq_data)

    # write data for figure
    write_pubs_seq_summary_csv(
        pubs_summary,
        "../output/data/fig12_all_publisher_seq_summary.csv")


if __name__ == "__main__":
    main()
