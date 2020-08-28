from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.helpers import (
    dictlist_keep_only_fields,
    list_to_dict_by_key,
    filter_rows_with_field_value
    )
from commonlibs_py.data_exporters import write_dictlist_csv
from collections import Counter


def filter_genredata(genredata_raw, keep_handcat=True):
    filtered_results = []
    for entry in genredata_raw:
        keep_entry = False
        if keep_handcat:
            if entry['hand_cat'] == "TRUE":
                keep_entry = True
        if keep_entry:
            filtered_results.append(entry)
    return filtered_results


def main():
    print("Create genre data translation table.")
    work_st_estc_csv = '../data/work/work_subject_topics_from_estc.csv'
    work_st_manual_csv = '../data/work/canon.csv'

    work_st_estc = read_csv_to_dict(work_st_estc_csv)
    work_st_estc_by_work_id = list_to_dict_by_key(work_st_estc, 'work_id')

    work_st_manual = read_csv_to_dict(work_st_manual_csv)
    work_st_manual = filter_genredata(work_st_manual)
    work_st_manual = dictlist_keep_only_fields(
        work_st_manual, ['work_titles', 'ddc_class_div_1', 'ddc_class'])
    work_st_manual = filter_rows_with_field_value(
        work_st_manual, 'ddc_class_div_1', '')
    work_st_manual_by_work_id = list_to_dict_by_key(
        work_st_manual, 'work_titles')

    transl_dict = {}
    for work_id in work_st_manual_by_work_id.keys():
        # category = work_st_manual_by_work_id[work_id][0]['Category']
        category = work_st_manual_by_work_id[work_id][0][
            'ddc_class_div_1']
        # category_s = work_st_manual_by_work_id[work_id][0]['Simple_category']
        category_s = work_st_manual_by_work_id[work_id][0]['ddc_class']
        if work_id in work_st_estc_by_work_id.keys():
            estc_cat = work_st_estc_by_work_id[work_id][0]['st_most_common']
            if estc_cat == '':
                continue
            else:
                if estc_cat in transl_dict.keys():
                    if category in transl_dict[estc_cat]['st_manual'].keys():
                        transl_dict[estc_cat]['st_manual'][category] += 1
                    else:
                        transl_dict[estc_cat]['st_manual'][category] = 1
                    if category_s in (
                            transl_dict[estc_cat]['st_manual_s'].keys()):
                        transl_dict[estc_cat]['st_manual_s'][category_s] += 1
                    else:
                        transl_dict[estc_cat]['st_manual_s'][category_s] = 1
                else:
                    transl_dict[estc_cat] = {}
                    transl_dict[estc_cat]['st_manual'] = {}
                    transl_dict[estc_cat]['st_manual_s'] = {}
                    transl_dict[estc_cat]['st_manual'][category] = 1
                    transl_dict[estc_cat]['st_manual_s'][category_s] = 1

    for key in transl_dict.keys():
        transl_dict[key]['most_common_manual'] = (
            Counter(transl_dict[key]['st_manual']).most_common(1)[0][0])
        transl_dict[key]['most_common_manual_s'] = (
            Counter(transl_dict[key]['st_manual_s']).most_common(1)[0][0])

    outlist = []
    for key, value in transl_dict.items():
        st_manual = value['most_common_manual']
        # if st_manual == "Ancient":
        #     continue
        outlist.append({
            'st_estc': key,
            'st_manual': st_manual,
            'st_manual_s': value['most_common_manual_s'],
            'st_manual_counts': (
                str(value['st_manual']).strip('{}').replace(',', ';')),
            'st_manual_s_counts': (
                str(value['st_manual_s']).strip('{}').replace(',', ';'))
            })

    write_dictlist_csv(
        outlist, '../data/work/subject_topic_translation_table.csv')


if __name__ == '__main__':
    main()
