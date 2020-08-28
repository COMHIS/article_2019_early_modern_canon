from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.helpers import (
    list_to_dict_by_key,
    dictlist_keep_only_fields,
    keep_rows_with_field_values,
    get_data_sorted_by_field)
from estclibs_py.data_prep import (
    # pubyear_validates,
    set_actorlink_vartypes,
    get_good_estc_titles_with_vartypes)
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.ticker import PercentFormatter
import math


def get_estc_id_booktrade_counts(estc_id, actorlinks_by_estc_id):
    resdict = {
        'estc_id': estc_id,
        'printer_count': 0,
        'bookseller_count': 0,
        'publisher_count': 0,
        'distinct_booktrade_actor_count': 0,
        'actor_ids': []}
    if estc_id in actorlinks_by_estc_id.keys():
        for actorlink in actorlinks_by_estc_id[estc_id]:
            if actorlink['actor_role_printer']:
                resdict['printer_count'] += 1
            if actorlink['actor_role_bookseller']:
                resdict['bookseller_count'] += 1
            if actorlink['primary_publisher']:
                resdict['publisher_count'] += 1
            if (actorlink['actor_role_printer'] or
                    actorlink['actor_role_bookseller'] or
                    actorlink['actor_role_publisher']):
                resdict['distinct_booktrade_actor_count'] += 1
                resdict['actor_ids'].append(actorlink['actor_id'])
    return resdict


def get_estc_titles_booktrade_numbers(estc_titles, actorlinks_by_estc_id):
    resdict = {}
    for item in estc_titles:
        estc_id = item['system_control_number']
        counts = get_estc_id_booktrade_counts(
            estc_id, actorlinks_by_estc_id)
        counts['publisher_statement'] = item['publisher']
        counts['publication_year'] = item['publication_year']
        counts['title'] = item['title']
        resdict[estc_id] = counts
    return resdict


def get_basic_actor_counts_for_item_for_year(
        booktrade_actor_counts_list_by_year, year):
    editions_for_year = 0
    distinct_actors_for_year = 0
    items_with_no_act = 0
    items_with_no_pub = 0
    items_with_no_pri = 0
    items_with_no_sel = 0
    total_pub = 0
    total_pri = 0
    total_sel = 0
    total_act = 0
    if year in booktrade_actor_counts_list_by_year.keys():
        year_subset = booktrade_actor_counts_list_by_year[year]
        editions_for_year = len(year_subset)
        year_actor_ids = []
        for item in year_subset:
            year_actor_ids.extend(item['actor_ids'])
            if item['distinct_booktrade_actor_count'] == 0:
                items_with_no_act += 1
            else:
                total_act += item['distinct_booktrade_actor_count']
            if item['publisher_count'] == 0:
                items_with_no_pub += 1
            else:
                total_pub += item['publisher_count']
            if item['printer_count'] == 0:
                items_with_no_pri += 1
            else:
                total_pri += item['printer_count']
            if item['bookseller_count'] == 0:
                items_with_no_sel += 1
            else:
                total_sel += item['bookseller_count']
        distinct_actors_for_year = len(set(year_actor_ids))
    items_with_actors = editions_for_year - items_with_no_act
    items_with_publishers = editions_for_year - items_with_no_pub
    items_with_printers = editions_for_year - items_with_no_pri
    items_with_booksellers = editions_for_year - items_with_no_sel
    act_per_item_with_actors = 0
    pri_per_item_with_pri = 0
    pub_per_item_with_pub = 0
    bs_per_item_with_bs = 0
    if items_with_actors > 0:
        act_per_item_with_actors = total_act / items_with_actors
    if items_with_printers > 0:
        pri_per_item_with_pri = total_pri / items_with_printers
    if items_with_publishers > 0:
        pub_per_item_with_pub = total_pub / items_with_publishers
    if items_with_booksellers > 0:
        bs_per_item_with_bs = total_sel / items_with_booksellers
    if editions_for_year > 0:
        items_with_no_act_of_all = items_with_no_act / editions_for_year
        items_with_no_pub_of_all = items_with_no_pub / editions_for_year
        items_with_no_pri_of_all = items_with_no_pri / editions_for_year
        items_with_no_sel_of_all = items_with_no_sel / editions_for_year
    else:
        items_with_no_act_of_all = 0
        items_with_no_pub_of_all = 0
        items_with_no_pri_of_all = 0
        items_with_no_sel_of_all = 0
    return {
        'year': year,
        'editions_for_year': editions_for_year,
        'distinct_booktrade_actors': distinct_actors_for_year,
        'items_with_no_actors': items_with_no_act,
        'items_with_no_publishers': items_with_no_pub,
        'items_with_no_printers': items_with_no_pri,
        'items_with_no_booksellers': items_with_no_sel,
        'items_with_no_actors_per_all_editions': items_with_no_act_of_all,
        'items_with_no_publishers_per_all_editions': items_with_no_pub_of_all,
        'items_with_no_printers_per_all_editions': items_with_no_pri_of_all,
        'items_with_no_booksellers_per_all_editions': items_with_no_sel_of_all,
        'items_with_publishers_per_all_editions': 1 - items_with_no_pub_of_all,
        'items_with_printers_per_all_editions': 1 - items_with_no_pri_of_all,
        'items_with_booksellers_per_all_editions': (
            1 - items_with_no_sel_of_all),
        'total_publishers': total_pub,
        'total_printers': total_pri,
        'total_booksellers': total_sel,
        'total_actors': total_act,
        'actors_per_item_with_actors': act_per_item_with_actors,
        'printers_per_item_with_printers': pri_per_item_with_pri,
        'publishers_per_item_with_publishers': pub_per_item_with_pub,
        'booksellers_per_item_with_booksellers': bs_per_item_with_bs,
    }


def set_estc_titles_work_ids(estc_titles, works_by_estc_id):
    for estc_title in estc_titles:
        if estc_title['system_control_number'] in works_by_estc_id.keys():
            work_id = works_by_estc_id[
                estc_title['system_control_number']][0]['finalWorkField']
        else:
            work_id = None
        estc_title['work_id'] = work_id


def get_canon_work_ids(canon, top_n):
    top_n_canon = canon[0:top_n]
    work_ids = []
    for item in top_n_canon:
        work_ids.append(item['work_titles'])
    return work_ids


def get_yearly_booktrade_actor_counts_estc_subset(
        estc_titles, actorlinks_by_estc_id):
    booktrade_actor_counts = get_estc_titles_booktrade_numbers(
        estc_titles, actorlinks_by_estc_id)
    booktrade_actor_counts_list = list(booktrade_actor_counts.values())
    booktrade_actor_counts_list = get_data_sorted_by_field(
        booktrade_actor_counts_list, 'publication_year')
    booktrade_actor_counts_list_by_year = list_to_dict_by_key(
        booktrade_actor_counts_list, 'publication_year')
    #
    year_first = booktrade_actor_counts_list[0]['publication_year']
    year_last = booktrade_actor_counts_list[-1]['publication_year']
    #
    year_counts = []
    for year in range(year_first, year_last + 1):
        this_year_counts = get_basic_actor_counts_for_item_for_year(
            booktrade_actor_counts_list_by_year, year)
        year_counts.append(this_year_counts)
    return year_counts


def limit_data_to_year_range(datalist, start_year, end_year):
    reslist = []
    for item in datalist:
        if item['year'] >= start_year and item['year'] <= end_year:
            reslist.append(item)
    reslist = get_data_sorted_by_field(reslist, 'year')
    return reslist


def write_actor_counts_markdown(n_actorlinks, n_unique_actors, mdfile):
    with open(mdfile, 'w') as markdownfile:
        markdownfile.write(
            "# Actor counts\n" +
            "Unique actors: " + str(n_unique_actors) + "\n" +
            "Actor links  : " + str(n_actorlinks) + "\n")


# -----------------------------------
# input csv file locations
# -----------------------------------

actors_csv = "../data/raw/unified_actors.csv"
estc_titles_csv = "../data/raw/estc_processed.csv"
actorlinks_csv = "../data/raw/unified_actorlinks_enriched.csv"
works_csv = "../data/raw/estc_works_roles.csv"
canon_csv = "../data/work/canon.csv"

# -----------------------------------
# read and prepare data
# -----------------------------------

print("Reading datafiles ...")

# actors and actorlinks
actors = read_csv_to_dict(actors_csv)
actorlinks = read_csv_to_dict(actorlinks_csv)
set_actorlink_vartypes(actorlinks)
actorlinks_by_estc_id = list_to_dict_by_key(actorlinks, 'curives')

# canon
canon = read_csv_to_dict(canon_csv)

# work data
works = read_csv_to_dict(works_csv)
works_by_estc_id = list_to_dict_by_key(works, 'system_control_number')

# estc editions
estc_titles = read_csv_to_dict(estc_titles_csv)
estc_titles = dictlist_keep_only_fields(
    estc_titles,
    ['system_control_number', 'publication_place',
     'publisher', 'publication_year', 'title'])
estc_titles = get_good_estc_titles_with_vartypes(estc_titles)
set_estc_titles_work_ids(estc_titles, works_by_estc_id)

# get canon 1000 subset of estc
top1000_canon_ids = get_canon_work_ids(canon, 1000)
estc_titles_canon = keep_rows_with_field_values(
    estc_titles, 'work_id', top1000_canon_ids)


# -----------------------------------
# Get stats
# -----------------------------------

# actors really basic stats
actorlinks_df = pd.DataFrame(actorlinks)
unique_actor_ids = set(actorlinks_df['actor_id'])
n_unique_actors = len(unique_actor_ids)
n_actorlinks = len(actorlinks)

# number of actors: page 7/42
write_actor_counts_markdown(
    n_actorlinks, n_unique_actors,
    "../output/data/actor_counts.md")

# actor statistics for all estc titles (with publication year)
all_estc_counts = get_yearly_booktrade_actor_counts_estc_subset(
    estc_titles, actorlinks_by_estc_id)
# write_dictlist_csv(
#     all_estc_counts,
#     'data_output/booktrade_actor_counts/estc_complete_actors_per_edition.csv')

# actor statistics for canon 1000 estc titles
canon_counts = get_yearly_booktrade_actor_counts_estc_subset(
    estc_titles_canon, actorlinks_by_estc_id)
# write_dictlist_csv(
#     canon_counts,
#     'data_output/booktrade_actor_counts/estc_canon1000_actors_per_edition.csv')

all_estc_counts_1500to1800 = limit_data_to_year_range(
    all_estc_counts, 1500, 1800)
canon_counts_1500to1800 = limit_data_to_year_range(
    canon_counts, 1500, 1800)


def get_decade_totals(yearly_counts, decades):
    decade_totals = []
    for decade in decades:
        this_decade = {
            'decade': decade,
            'editions_for_decade': 0,
            'distinct_booktrade_actors': 0,
            'items_with_no_actors': 0,
            'items_with_no_publishers': 0,
            'items_with_no_printers': 0,
            'items_with_no_booksellers': 0,
            'total_publishers': 0,
            'total_printers': 0,
            'total_booksellers': 0,
            'total_actors': 0,
            }
        for count_item in yearly_counts:
            if (math.floor(count_item['year'] / 10) * 10) == decade:
                this_decade['editions_for_decade'] += count_item['editions_for_year']
                this_decade['distinct_booktrade_actors'] += count_item['distinct_booktrade_actors']
                this_decade['items_with_no_actors'] += count_item['items_with_no_actors']
                this_decade['items_with_no_publishers'] += count_item['items_with_no_publishers']
                this_decade['items_with_no_printers'] += count_item['items_with_no_printers']
                this_decade['items_with_no_booksellers'] += count_item['items_with_no_booksellers']
                this_decade['total_publishers'] += count_item['total_publishers']
                this_decade['total_printers'] += count_item['total_printers']
                this_decade['total_booksellers'] += count_item['total_booksellers']
                this_decade['total_actors'] += count_item['total_actors']
        decade_totals.append(this_decade)
        this_decade['items_with_no_actors_per_all_editions'] = (
            this_decade['items_with_no_actors'] / this_decade['editions_for_decade'])
        this_decade['items_with_no_publishers_per_all_editions'] = (
            this_decade['items_with_no_publishers'] / this_decade['editions_for_decade'])
        this_decade['items_with_no_printers_per_all_editions'] = (
            this_decade['items_with_no_printers'] / this_decade['editions_for_decade'])
        this_decade['items_with_no_booksellers_per_all_editions'] = (
            this_decade['items_with_no_booksellers'] / this_decade['editions_for_decade'])
        this_decade['items_with_publishers_per_all_editions'] = (
            1 - this_decade['items_with_no_publishers_per_all_editions'])
        this_decade['items_with_printers_per_all_editions'] = (
            1 - this_decade['items_with_no_printers_per_all_editions'])
        this_decade['items_with_booksellers_per_all_editions'] = (
            1 - this_decade['items_with_no_booksellers_per_all_editions'])
        this_decade['actors_per_item_with_actors'] = (
            this_decade['total_actors'] / this_decade['editions_for_decade'])
        this_decade['printers_per_item_with_printers'] = (
            this_decade['total_printers'] / this_decade['editions_for_decade'])
        this_decade['publishers_per_item_with_publishers'] = (
            this_decade['total_publishers'] / this_decade['editions_for_decade'])
        this_decade['booksellers_per_item_with_booksellers'] = (
            this_decade['total_booksellers'] / this_decade['editions_for_decade'])
    return decade_totals


decades = range(1500, 1800, 10)
all_estc_decade_totals = get_decade_totals(all_estc_counts_1500to1800, decades)
canon_decade_totals = get_decade_totals(canon_counts_1500to1800, decades)

plot_df = pd.DataFrame(data=all_estc_decade_totals)
canon_df = pd.DataFrame(data=canon_decade_totals)

plot_df['items_with_actors'] = (
    plot_df['editions_for_decade'] - plot_df['items_with_no_actors'])
plot_df['titles_per_unique_actor'] = (
    plot_df['items_with_actors'] / plot_df['distinct_booktrade_actors'])

plot_df['canon_no_actors'] = canon_df['items_with_no_actors_per_all_editions']
plot_df['canon_no_pub'] = canon_df['items_with_no_publishers_per_all_editions']
plot_df['canon_no_pri'] = canon_df['items_with_no_printers_per_all_editions']
plot_df['canon_no_sel'] = canon_df[
    'items_with_no_booksellers_per_all_editions']

plot_df['canon_printers_per'] = canon_df['printers_per_item_with_printers']
plot_df['canon_publishers_per'] = canon_df[
    'publishers_per_item_with_publishers']
plot_df['canon_booksellers_per'] = canon_df[
    'booksellers_per_item_with_booksellers']


# -----------------------------------
# Draw plots
# -----------------------------------

# Figure 9: has booktrade actors in category X -- canon and all
# save data csv
plot_df.to_csv("../output/data/fig9_actors_missing_in_category.csv", index=False)

# draw plot with the R-script

# make and save figure
# plt.figure(figsize=(12, 8), dpi=100)
# plt.plot(plot_df['year'], plot_df['items_with_no_publishers_per_all_editions'],
#          "g", label="All ESTC / publishers")
# plt.plot(plot_df['year'], plot_df['items_with_no_printers_per_all_editions'],
#          "r", label="All ESTC / printers")
# plt.plot(plot_df['year'],
#          plot_df['items_with_no_booksellers_per_all_editions'],
#          "b", label="All ESTC / booksellers")
# plt.plot(plot_df['year'], plot_df['canon_no_pub'],
#          "--g", label="Canon1000 / publishers")
# plt.plot(plot_df['year'], plot_df['canon_no_pri'],
#          "--r", label="Canon1000 / printers")
# plt.plot(plot_df['year'], plot_df['canon_no_sel'],
#          "--b", label="Canon1000 / booksellers")
# plt.title("Titles with no booktrade actors in category")
# plt.xlabel("Year")
# plt.ylabel("Titles")
# plt.gca().yaxis.set_major_formatter(PercentFormatter(1))
# plt.legend()
# plt.savefig("../output/figures/fig9_actors_missing_in_category.png")
# plt.close()
