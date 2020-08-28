from commonlibs_py.helpers import (
    list_to_dict_by_key,
    # filter_rows_with_field_value
    )
from commonlibs_py.data_importers import read_csv_to_dict
import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.cm as cmap
from commonlibs_py.genre_helpers import create_category_hierarchy_table
import math


def limit_cases_by_master_category_list(cases, master_category_list,
                                        category_hierachies):
    category_hierachies_by_master = list_to_dict_by_key(
        category_hierachies, 'master_category')
    outcases = set()
    for master_cat in master_category_list:
        for item in category_hierachies_by_master[master_cat]:
            outcase = item['child_category']
            if outcase in cases:
                outcases.add(outcase)
    return list(outcases)


def trim_axs(axs, N):
    """little helper to massage the axs list to have correct length..."""
    axs = axs.flat
    for ax in axs[N:]:
        ax.remove()
    return axs[:N]


def get_plot_cases(plotdata, subject_topic_level="simple"):
    cases = []
    for key in plotdata[0]:
        if subject_topic_level == "simple":
            if key.split("*")[0] == 'subject_topic_simple_percentages':
                cases.append(key.split("*")[1])
        else:
            if key.split("*")[0] == 'subject_topic_percentages':
                cases.append(key.split("*")[1])
    cases.remove('uncategorized')
    return cases


def draw_genrepubplot(
        pltdat, cases,
        ncols, figsizemulti=3, plotlevel="simple",
        outpng="testout_x.png"):
    cols = ncols
    rows = math.ceil(len(cases) / cols)
    figwidth = ncols * figsizemulti
    figheight = rows * figsizemulti
    #
    fig, axs = plt.subplots(rows, cols,
                            sharex=True, sharey=True,
                            figsize=(figwidth, figheight))
    axs = trim_axs(axs, len(cases))
    colour_i = 0
    for ax, case in zip(axs, cases):
        ax.set_title(case, fontsize=10)
        if plotlevel == "simple":
            x_col = 'subject_topic_simple_percentages*' + case
            z_col = 'subject_topic_simple_counts*' + case
        else:
            x_col = 'subject_topic_percentages*' + case
            z_col = 'subject_topic_counts*' + case
        ax.scatter(x=x_col, y='canon_ratio', s=z_col,
                   data=pltdat, c=cmap.tab20(colour_i), alpha=0.5)
        ax.set_xlim((0, 1))
        ax.set_ylim((0, 1))
        if colour_i == 0:
            ax.set_ylabel('canon / all titles', position=(0, -0.1))
        elif colour_i == len(cases) - 1:
            ax.set_xlabel(
                'subject topic percentage of all works', position=(-0.1, 0))
        colour_i += 1
    #
    fig.savefig(outpng)


def draw_genrepubplot_heatmap(
        pltdat, cases, ncols, figsizemulti=3, plotlevel="simple",
        outpng="testout_x.png"):
    col_maps = ['Greys', 'Purples', 'Blues', 'Greens', 'Oranges', 'Reds',
                'YlOrBr', 'YlOrRd', 'OrRd', 'PuRd', 'RdPu', 'BuPu',
                'GnBu', 'PuBu', 'YlGnBu', 'PuBuGn', 'BuGn', 'YlGn']
    cols = ncols
    rows = math.ceil(len(cases) / cols)
    figwidth = cols * figsizemulti
    figheight = rows * figsizemulti
    #
    fig, axs = plt.subplots(rows, cols,
                            sharex=True, sharey=True,
                            figsize=(figwidth, figheight))
    axs = trim_axs(axs, len(cases))
    i = 0
    cmap_i = 0
    for ax, case in zip(axs, cases):
        cmap_name = col_maps[cmap_i]
        ax.set_title(case, fontsize=10)
        if plotlevel == "simple":
            x_col = 'subject_topic_simple_percentages*' + case
            z_col = 'subject_topic_simple_counts*' + case
        else:
            x_col = 'subject_topic_percentages*' + case
            z_col = 'subject_topic_counts*' + case
        ax.hist2d(x=x_col, y='canon_ratio',
                  bins=10,
                  range=[(0, 1), (0, 1)],
                  weights=z_col,
                  density=True,
                  data=pltdat,
                  cmap=cmap_name)
        if i == 0:
            ax.set_ylabel('canon / all titles', position=(0, -0.1))
        elif i == len(cases) - 1:
            ax.set_xlabel(
                'subject topic percentage of all works', position=(-0.1, 0))
        i += 1
        cmap_i += 1
        if cmap_i > len(col_maps) - 1:
            cmap_i = 0
    fig.savefig(outpng)


def set_plotdata_vartypes(plotdata):
    for item in plotdata:
        for key in item.keys():
            splitkey = key.split("*")
            if splitkey[0] == 'subject_topic_simple_percentages':
                item[key] = float(item[key])
            if splitkey[0] == 'subject_topic_simple_counts':
                item[key] = int(item[key])
            if splitkey[0] == 'subject_topic_percentages':
                item[key] = float(item[key])
            if splitkey[0] == 'subject_topic_counts':
                item[key] = int(item[key])
        item['mid_percentile'] = int(item['mid_percentile'])
        item['canon_n'] = int(item['canon_n'])
        item['non_canon_n'] = int(item['non_canon_n'])
        item['total_n'] = item['canon_n'] + item['non_canon_n']
        item['canon_ratio'] = float(item['canon_ratio'])


# genre hierarchy table
create_category_hierarchy_table()
category_hierachies = read_csv_to_dict('../data/work/category_hierarchy.csv')

# from analysis_publisher_genre_makeup.py
plotdata = read_csv_to_dict(
    "../data/work/canon_individual_publisher_counts_subject_topics_all.csv")
set_plotdata_vartypes(plotdata)


filtered_plotdata = []
for item in plotdata:
    if item['total_n'] > 49:
        filtered_plotdata.append(item)

pltdat = pd.DataFrame.from_records(filtered_plotdata)
pltdat_as_array = pltdat.values
# pltdat.to_csv("testout.csv", index=False)

# DRAW PLOTS
plotlevel = "simple"
cases = get_plot_cases(plotdata, subject_topic_level=plotlevel)
draw_genrepubplot(pltdat, cases, ncols=5, figsizemulti=3,
                  plotlevel=plotlevel,
                  outpng="../output/figures/fig13_publisher_topics.png")
