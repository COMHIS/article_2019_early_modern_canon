from work_genres_py.extract_estc_data import main as get_estc_genres
from work_genres_py.translation_table import main as create_translations
from work_genres_py.combined_st import main as create_combined_genredata


def main():
    # find subject topics in ESTC for each work, pick the most common one
    get_estc_genres()
    # pair the above with the hand curated set and write a translation table
    create_translations()
    # apply the above translation table to the works missing a genre
    create_combined_genredata()


if __name__ == '__main__':
    main()
