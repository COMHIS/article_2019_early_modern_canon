from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.data_exporters import write_dictlist_csv

# NOTES:
# - Run data_prep_publisher_shares.py to generate the interim input data
#   shared by this and other plots.
# - Run fig10_figure.R to generate the figure.

# read input data
estc_pub_percentiles = read_csv_to_dict(
    "../data/work/estc_titles_pub_percentiles.csv")

# create yearly summary. Set percentile steps and years.
percentile_steps = [1, 5, 10, 20, 40, 100]
years = range(1500, 1800)

percentile_share_list = []
for year in years:
    year_stats = {'year': year}
    for key in percentile_steps:
        year_stats[key] = 0
    for item in estc_pub_percentiles:
        if int(item['pubyear']) == year:
            for percentile_step in percentile_steps:
                if int(item['percentile']) <= percentile_step:
                    year_stats[percentile_step] += 1
                    break
    percentile_share_list.append(year_stats)

# write plotdata. Draw plot in separate R script to simplify vis unification.
write_dictlist_csv(
    percentile_share_list,
    "../output/data/fig10_booktrade_percentile_share.csv")
