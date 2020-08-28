from commonlibs_py.helpers import (
    list_to_dict_by_key,
    )
from commonlibs_py.data_exporters import write_dictlist_csv
from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.canon_helpers import (
    get_top_n_canon_work_ids,
    get_canon_estc_ids,
    get_percentile_step_int)


# csv locations
workdata_csv = "../data/raw/estc_works_roles.csv"
canon_csv = "../data/work/canon.csv"
estc_titles_percentiles_csv = "../data/work/estc_titles_pub_percentiles.csv"

# setup input dataset
titles_percentiles = read_csv_to_dict(estc_titles_percentiles_csv)
workdata = read_csv_to_dict(workdata_csv)
workdata_by_estc_id = list_to_dict_by_key(workdata, 'system_control_number')
canon = read_csv_to_dict(canon_csv)
canon1000_work_ids = get_top_n_canon_work_ids(canon, 1000)
canon1000_estc_ids = get_canon_estc_ids(canon1000_work_ids, workdata)


# count portion of canon/noncanon works for each publisher percentile
# portion of canon works published by top1, top5 for each year
percentile_steps = [1, 5, 10, 20, 40, 100]
# percentile_steps = list(range(1, 101, 1))

topn_counts = dict()
for percentile_step in percentile_steps:
    topn_counts[str(percentile_step)] = {
        'percentile': percentile_step,
        'canon_n': 0,
        'non_canon_n': 0,
    }

for item in titles_percentiles:
    item_percentile = item['percentile']
    item_percentile_step = get_percentile_step_int(
        int(item['percentile']), percentile_steps)
    item_curives = item['curives']
    if item_curives in workdata_by_estc_id.keys():
        item_work_id = workdata_by_estc_id[item_curives][0]['finalWorkField']
        item_is_canon = item_work_id in canon1000_work_ids
        if item_is_canon:
            group_key = "canon_n"
        else:
            group_key = "non_canon_n"
        topn_key = str(item_percentile_step)
        topn_counts[topn_key][group_key] += 1


# get canon and non_canon totals
canon_sum = 0
non_canon_sum = 0
for value in topn_counts.values():
    canon_sum += value['canon_n']
    non_canon_sum += value['non_canon_n']

for value in topn_counts.values():
    value['canon_share_of_whole_canon'] = value['canon_n'] / canon_sum
    value['non_canon_share_of_whole_non_canon'] = (
        value['non_canon_n'] / non_canon_sum)
    if (value['canon_n'] + value['non_canon_n']) == 0:
        value['percentile_internal_canon_fraction'] = 0
    else:
        value['percentile_internal_canon_fraction'] = (
            value['canon_n'] / (value['canon_n'] + value['non_canon_n']))

# output fields:
# canon_n = number of editions linked with percentile, in canon
# non_canon_n = number of editions, linked with percentile, not in canon
# canon_share_of_whole_canon = canon_n divided by total number of editions
#     in canon
# non_canon_share_of_whole_non_canon = non_canon_n divided by total number of
#     editions in non_canon
# percentile_internal_canon_fraction = percentile canon_n divided by percentile
#     canon_n + non_canon_n

output_as_list = list(topn_counts.values())
write_dictlist_csv(
    output_as_list,
    '../output/data/fig11_canon_share_by_publisher_percentile.csv')
