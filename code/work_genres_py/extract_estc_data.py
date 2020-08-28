from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.helpers import (
    dictlist_keep_only_fields,
    list_to_dict_by_key,
    )
from commonlibs_py.data_exporters import write_dictlist_csv
from collections import Counter
import re


def get_subject_topic_list(st_string):
    if st_string == "NA":
        return []
    st_string = st_string.lower()
    st_list = re.split(', |; |;', st_string)
    final_st_list = []
    for item in st_list:
        item = item.strip(".")
        item = item.strip()
        item = item.strip(".")
        final_st_list.append(item)
    return final_st_list


def main():
    print("Get ESTC genre data.")
    # input csv files
    estcdata_csv = (
        "../../estc-data-unified/estc-cleaned-initial/estc_processed.csv")
    workdata_csv = "../data/raw/estc_works_roles.csv"

    # read csvs
    workdata = read_csv_to_dict(workdata_csv)
    estcdata = read_csv_to_dict(estcdata_csv)
    estcdata = dictlist_keep_only_fields(
        estcdata, ["system_control_number", "title", "subject_topic"])

    # group by ids
    estcdata_by_curives = list_to_dict_by_key(
        estcdata, "system_control_number")
    # workdata_by_curives = list_to_dict_by_key(
    #     workdata, "system_control_number")
    workdata_by_workid = list_to_dict_by_key(workdata, "finalWorkField")

    # setup main loop
    further_workdata = []
    missing_ids_in_estcdata = []

    # create output list
    for key, value in workdata_by_workid.items():
        #
        work_all_topics = []
        for entry in value:
            curives = entry['system_control_number']
            # <<<debug>>> if curives is missing from estcdata...
            if curives not in estcdata_by_curives.keys():
                print("curives " + key + " missing from ESTCdata")
                missing_ids_in_estcdata.append(key)
                continue
            # <<<end debug>>>
            st_string = estcdata_by_curives[curives][0]['subject_topic']
            st_list = get_subject_topic_list(st_string)
            work_all_topics.extend(st_list)
        #
        st_counts = Counter(work_all_topics)
        st_counts_dict = dict(st_counts)
        st_unq_list = list(st_counts)
        st_unq_list.sort()
        most_common = st_counts.most_common(1)
        if len(most_common) > 0:
            most_common = most_common[0][0]
        else:
            most_common = ""
        sorted_counts_dict = sorted(
            st_counts_dict.items(), key=lambda x: x[1], reverse=True)
        sorted_counts_str_list = []
        for item in sorted_counts_dict:
            line = item[0] + ": " + str(item[1])
            sorted_counts_str_list.append(line)
        wd_entry = {
            'work_id': key,
            'titles': value,
            'st_list': work_all_topics,
            'n_titles': len(value),
            'st_counter': st_counts,
            'st_most_common': most_common,
            'st_unq_list': st_unq_list,
            'st_unq_list_str': "; ".join(st_unq_list),
            'st_counts_sorted_dict': sorted_counts_dict,
            'st_sorted_counts_str': "; ".join(sorted_counts_str_list),
            'st_n': len(work_all_topics)
        }
        #
        further_workdata.append(wd_entry)

    # setup clean output
    outdata = dictlist_keep_only_fields(
        further_workdata,
        ['work_id', 'n_titles', 'st_most_common', 'st_unq_list_str',
         'st_sorted_counts_str', 'st_n'])

    # write output
    write_dictlist_csv(
        outdata, '../data/work/work_subject_topics_from_estc.csv')


if __name__ == "__main__":
    main()
