from commonlibs_py.helpers import list_to_dict_by_key
from commonlibs_py.data_exporters import write_dictlist_csv
from commonlibs_py.data_importers import read_csv_to_dict
from estclibs_py.data_prep import pubyear_validates
from commonlibs_py.canon_helpers import (
    get_top_n_canon_work_ids,
    get_canon_estc_ids)


def find_middle(input_list):
    middle = float(len(input_list))/2
    if middle % 2 != 0:
        return input_list[int(middle - .5)]
    else:
        return input_list[int(middle-1)]


def get_publisher_max_min_mid_percentiles(
        actor_id, publisher_yearly_ranks_by_actor_id):
    publisher_ranks = publisher_yearly_ranks_by_actor_id[actor_id]
    if len(publisher_ranks) == 0:
        return None
    all_ranks = []
    for entry in publisher_ranks:
        all_ranks.append(int(entry['percentile']))
    all_ranks.sort()
    middle_val = str(find_middle(all_ranks))
    max_val = str(all_ranks[0])
    min_val = str(all_ranks[-1])
    return {
        'max_val': max_val,
        'mid_val': middle_val,
        'min_val': min_val,
        'all_percentiles': all_ranks
    }


def get_publisher_canon_non_canon_counts(
        actor_id, canon_estc_ids, actorlinks_by_actor_id, workdata_by_estc_id):
    canon_n = 0
    non_canon_n = 0
    for actorlink in actorlinks_by_actor_id[actor_id]:
        if actorlink['primary_publisher'] == "True":
            if actorlink['curives'] in canon_estc_ids:
                canon_n += 1
            elif actorlink['curives'] in workdata_by_estc_id.keys():
                non_canon_n += 1
    return {'canon_n': canon_n, 'non_canon_n': non_canon_n}


def get_publisher_pubyears_minmax(actor_id, actorlinks_by_actor_id):
    this_actorlinks = actorlinks_by_actor_id[actor_id]
    this_all_pubyears = []
    for actorlink in this_actorlinks:
        if actorlink['primary_publisher'] == "True":
            if pubyear_validates(actorlink['pubyear']):
                this_all_pubyears.append(actorlink['pubyear'])
    if len(this_all_pubyears) == 0:
        return {'min_pubyear': None, 'max_pubyear': None}
    else:
        return {
            'min_pubyear': min(this_all_pubyears),
            'max_pubyear': max(this_all_pubyears)}


def main():
    workdata_csv = "../data/raw/estc_works_roles.csv"
    canon_csv = "../data/work/canon.csv"
    actors_csv = "../data/raw/unified_actors.csv"
    actorlinks_csv = "../data/raw/unified_actorlinks_enriched.csv"
    publisher_yearly_ranks_csv = (
        "../data/work/publisher_id_10year_slices_rank_and_percentile.csv")

    actors = read_csv_to_dict(actors_csv)
    actors_by_id = list_to_dict_by_key(actors, 'actor_id')
    actorlinks = read_csv_to_dict(actorlinks_csv)
    actorlinks_by_actor_id = list_to_dict_by_key(actorlinks, 'actor_id')

    publisher_yearly_ranks = read_csv_to_dict(publisher_yearly_ranks_csv)
    publisher_yearly_ranks_by_actor_id = list_to_dict_by_key(
        publisher_yearly_ranks, 'actor_id')

    workdata = read_csv_to_dict(workdata_csv)
    workdata_by_estc_id = list_to_dict_by_key(
        workdata, 'system_control_number')

    canon = read_csv_to_dict(canon_csv)
    canon1000_work_ids = get_top_n_canon_work_ids(canon, 1000)
    canon1000_estc_ids = get_canon_estc_ids(canon1000_work_ids, workdata)

    unq_pub_ids_in_actorlinks = set()
    for actorlink in actorlinks:
        if actorlink['primary_publisher'] == "True":
            unq_pub_ids_in_actorlinks.add(actorlink['actor_id'])

    # percentiles_missing = []
    # percentiles_missing is for debug / logging only
    results = dict()
    for actor_id in unq_pub_ids_in_actorlinks:
        if actor_id not in publisher_yearly_ranks_by_actor_id:
            # percentiles_missing.append(actor_id)
            continue
        this_pub_percentiles = get_publisher_max_min_mid_percentiles(
            actor_id, publisher_yearly_ranks_by_actor_id)
        if this_pub_percentiles is None:
            continue
        results[actor_id] = {
            'actor_id': actor_id,
            'canon_n': 0,
            'non_canon_n': 0,
            'percentiles': this_pub_percentiles['all_percentiles'],
            'max_percentile': this_pub_percentiles['max_val'],
            'mid_percentile': this_pub_percentiles['mid_val'],
            'min_percentile': this_pub_percentiles['min_val']
        }

    for value in results.values():
        canon_counts = get_publisher_canon_non_canon_counts(
            value['actor_id'], canon1000_estc_ids,
            actorlinks_by_actor_id, workdata_by_estc_id)
        value['canon_n'] = canon_counts['canon_n']
        value['non_canon_n'] = canon_counts['non_canon_n']
        if value['non_canon_n'] + value['canon_n'] == 0:
            value['canon_ratio'] = 0
        else:
            value['canon_ratio'] = (value['canon_n'] / (
                value['non_canon_n'] + value['canon_n']))

    # add names
    for value in results.values():
        value['actor_name'] = actors_by_id[value['actor_id']][0]['name_unified']
        puby_minmax = get_publisher_pubyears_minmax(
            value['actor_id'], actorlinks_by_actor_id)
        value['publication_years_first'] = puby_minmax['min_pubyear']
        value['publication_years_last'] = puby_minmax['max_pubyear']

    results_all = list(results.values())

    write_dictlist_csv(
        results_all,
        '../data/work/canon_individual_publisher_counts_all.csv')


if __name__ == "__main__":
    main()
