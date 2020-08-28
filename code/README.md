# code/


## Python

Python code has been written for Python 3.6. Required libraries can be found in `requirements_py.txt`. Install them by `pip install -r requirements_py.txt` (preferably in a Python virtual environment).


## Data prep code

To create the processed data needed by the python scripts, and possibly others run `data_prep_main.py`. This script needs the `data/work/canon.csv` processed data file. Other required dataset are in `data/raw`.


## Figures code

* Figure 3-1. Total documents, works, and canon items in the ESTC per decade (1500-1800)
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig1.R`
  
* Figure 3-2. The Full Canon. Canonical works have been sorted by the first publication year. The individual dots indicate the publishing year for the initial publication and all subsequent reprints.
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig2.R`

* Figure 3-3. Works that were most frequently printed in one or more decades between1500 and1800. The point size indicates the number of reprints for each work (rows) during the given decade (columns).
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig3.R`

* Figure 3-4. Temporal variation in the relative frequencies of the most common subject-topics in the canon, 1500-1800.
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig4.R`

* Figure 3-5. The most popular subject-topics for the ten most printed works in each decade from 1500 to 1800.
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig5.R`

* Figure 3-6. Post-mortem publication frequencies. The percentage of authors in ESTC with post-mortem publications during the first 50 years after death, grouped by decade (1470-1800). This analysis includes the 2,514 authors whose lifetime data is available for the investigated period.
  * Author: Leo
  * Data: `data.R`
  * Figure: `fig6.R`

* Figure 3-7. Top authors between 1500 and 1800. The point size indicates the number of publications for each author, including reprints (rows), per year (columns). The color indicates publication before (red) and after (blue) death, respectively. The authors have been sorted by their death year.
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig7.R`

* Figure 3-8. Timeline of Shakespeare’s publications included in canon. The point size indicates the number of publications (including reprints) for the indicated works (rows) by decade (columns). The publishers have been highlighted in different colors.
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig8.R`
  
* Figure 3-9. Titles with missing book trade actor data. This figure charts out the coverage of the book trade actor data, as found in the catalogue records, between 1500 and 1800.
  * Author: Ville
  * `fig9_titles_missing_actors.py`
  * `fig9_figure.R`  

* Figure 3-10. Share of publications by 1st publisher percentile.
  * Author: Ville
  * Data: `fig10_data.py`
  * Figure: `fig10_figure.R`

* Figure 3-11. Share of Canon by publisher percentiles (for unique works as derived from the work field dataset). The most prominent publishers (the first percentile) published a disproportionately larger share of canonical works compared to the other publishers, with the imbalance growing progressively for each lower percentile.
  * Author: Ville
  * Data: `fig11_data.py`
  * Figure: `fig11_figure.R`

* Figure 3-12. Publishing and reprint patterns by publisher role in the printing sequence.
  * Author: Ville
  * Data: `fig12_data.py`
  * Figure: `fig12_figure.R`

* Figure 3-13. Publisher subject topic specialization and canon share.
  * Author: Ville
  * Data for table & figure in repo.
  * Vis code ported to R.

* Figure 3-14. Works by female authors in the data-driven canon per decade.
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig14.R`
  
* Figure 3-15. Share of publications by place for the top publication places excluding London, 1500=1800.
  * Author: Mikko + Leo
  * Data: `data.R`
  * Figure: `fig15.R`  
  
* Figure 3-16. Movement of canonical editions from original print location.
  * Author: Mark
  * Produces data rather than vis. Specifically a gefx file in output/data/work_movements.gefx. This can then be used to produce a network/GIS visualization with other software. 
  * Outputs: `output/figures/fig_16_visualizations/` 
  * Code: `fig16_movement_canon_editions_from_orig.r`

* Figure 3-17. Number of prints per capita, 1700-1800.
  * Author: Mark
  * Code: `fig17_prints_per_capita.r`

* Figure 3-18. The fraction of canonical editions compared to all editions for Glasgow, London, Dublin, Edinburgh, Cambridge, Oxford, and Boston.
  * Author: Mark
  * Code: `fig18_can_fraction_cities`

* Figure 3-19. The dominant book formats1 for the most frequent subject topics.
  * Author: Leo
  * Data: `data.R`
  * Figure: `fig19.R`

* Figure 3-20. Diversity of formats for works
  * Author: Leo
  * Data: `data.R`
  * Figure: `fig20.R`

## Tables 

* Scripts for replicating table outputs are in: `table_data.r`
  * Table 3-1. Top 20 Canonical Works
  * Table 3-2. Top-five canonical literary works 
  * Table 3-3. Top authors and works, canon editions, and total editions between 1500 and 1800.
  * Table 3-4: Distribution of subject topics among the works by top authors, 1500 to 1800.
  * Table 3-5. Top printing locations in the whole ESTC and in the canon, 1500-1800.
  * Table 3-6. Locations for the first editions and for the subsequent editions of canonical works, 1500=1800.






