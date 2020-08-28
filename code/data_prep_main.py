from data_prep_publisher_shares import (
    main as data_prep_pub_shares)
from data_prep_work_genres import (
    main as data_prep_genres)
from data_prep_publisher_canon_shares import (
    main as data_prep_pub_canon_shares)

# make sure canon.csv is generated and exists in data/work

print("\ndata_prep_pub_shares ...\n")
data_prep_pub_shares()
print("\ndata_prep_genres ...\n")
data_prep_genres()
print("\ndata_prep_pub_canon_shares ...\n")
data_prep_pub_canon_shares()
print("\ndata prep done.\n")
