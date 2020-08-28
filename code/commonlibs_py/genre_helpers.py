from commonlibs_py.helpers import (
    dictlist_keep_only_fields,
    filter_rows_with_field_value)
from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.data_exporters import write_dictlist_csv
from work_genres_py.translation_table import filter_genredata


def create_category_hierarchy_table():
    print("Creating genre category hierarchy table ...")

    work_st_manual_csv = '../data/work/canon.csv'
    work_st_manual = read_csv_to_dict(work_st_manual_csv)
    work_st_manual = filter_genredata(work_st_manual)
    work_st_manual = dictlist_keep_only_fields(
        work_st_manual, ['work_titles', 'ddc_class_div_1', 'ddc_class'])
    work_st_manual = filter_rows_with_field_value(
        work_st_manual, 'ddc_class_div_1', '')
    # len(work_st_manual)

    genre_pairs = {}
    for item in work_st_manual:
        if item['ddc_class'] in genre_pairs.keys():
            genre_pairs[item['ddc_class']].append(item['ddc_class_div_1'])
        else:
            genre_pairs[item['ddc_class']] = [item['ddc_class_div_1']]

    for key, value in genre_pairs.items():
        genre_pairs[key] = list(set(value))

    for key, value in genre_pairs.items():
        valueset = set(value)
        for other_key, other_value in genre_pairs.items():
            other_valueset = set(other_value)
            if len(valueset.intersection(other_valueset)) > 0:
                if key != other_key:
                    print(key + " -&- " + other_key + " -- intersect: " +
                          str(valueset.intersection(other_valueset)))

    outlist = []
    for key, value in genre_pairs.items():
        for item in value:
            outlist.append({
                'child_category': item,
                'master_category': key
                })

    write_dictlist_csv(outlist, '../data/work/category_hierarchy.csv')
    # return outlist
