from commonlibs_py.helpers import (
    list_to_dict_by_key)


def get_top_n_canon_work_ids(canon, top_n):
    topworks = []
    i = 0
    while i < top_n:
        topworks.append(canon[i]['work_titles'])
        i += 1
    return topworks


def get_canon_estc_ids(canon_work_ids, workdata):
    canon_estc_ids = []
    workdata_by_work_id = list_to_dict_by_key(workdata, 'finalWorkField')
    for work_id in canon_work_ids:
        for line in workdata_by_work_id[work_id]:
            canon_estc_ids.append(line['system_control_number'])
    return canon_estc_ids


def get_percentile_step_int(percentile_value, percentile_steps):
    percentile_steps.sort()
    for percentile_step in percentile_steps:
        if int(percentile_value) <= percentile_step:
            return percentile_step


def get_workid_curives_set(work_id, workdata_by_work_id):
    work_curives = set()
    for item in workdata_by_work_id[work_id]:
        work_curives.add(item['system_control_number'])
    return work_curives
