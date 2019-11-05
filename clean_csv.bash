#! /bin/bash

for file in "$@"; do
  if [ ! -f "$file" ]; then echo "The file does not exist" && break; fi

  if [ "${file##*.}" = "csv" ]; then
    # Removing the BOM
    # | Use of a BOM is neither required nor recommended for UTF-8
    # source: https://www.unicode.org/versions/Unicode12.0.0/ch02.pdf#G19273
    # this should touch almost all files (1224255 at the time of writing)
    LANG=C LC_ALL=C sed -i '1s/^\xEF\xBB\xBF//' "$file"

    # Temporaryly removing the CRs
    # We'll add them back at the end
    # this should touch 6957 files
    LANG=C LC_ALL=C sed -i -E 's/\r//g' "$file"

    # Removing Unicode Character 'NEXT LINE (NEL)' (U+0085)
    # this is not strictly necessary but might avoid problems downstream
    # this should touch 26 files
    LANG=C LC_ALL=C sed -i 's/\xC2\x85/\x20/g' "$file"

    # Cleaning col "Décision" in actes.csv files
    # between 2018-01-24 and 2018-04-28
    # this should fix 11619 files
    if [[ $file =~ .*2018012[6789].*_actes\.csv ||
          $file =~ .*2018013.*_actes\.csv ||
          $file =~ .*20180[23].*_actes\.csv ||
          $file =~ .*201804[01].*_actes\.csv ||
          $file =~ .*2018042[012345678].*_actes\.csv ]]; then
      sed -i -E 's/([^"])" {1,2}"([^"])/\1 \2/g' "$file"
      sed -i -E 's/" ;/";/g' "$file"
      sed -i -E 's/; "/;"/g' "$file"
    fi

    # Cleaning col "Origine_Fonds_Info"
    # in ets.csv and ets_nouveau_modifie_EVT.csv files
    # between 2018-01-26 and 2018-02-01
    # this should fix 1730 files
    if [[ $file =~ .*20180[12].*_ets.csv ||
          $file =~ .*20180[12].*_ets_nouveau_modifie_EVT\.csv ]]; then
      sed -i -E 's/;"*([^";]*|([^";]*""[^";]*)*)"* - "(Précédent exploitant|Précédent propriétaire|Précédent propriétaire exploitant|Loueur du fonds|Propriétaire non exploitant)" - "*([^";]*|([^";]*""[^";]*)*)"*;/;"\1 - \3 - \4";/' "$file"
      sed -i -E 's/;"([^";]*|([^";]*""[^";]*)*)" -  - ;/;"\1 -  - ";/' "$file"
    fi

    # clean the /;"N;/ pattern
    # in EVT.csv files between 2017-08-24 and 2017-11-20
    # and in actes.csv on 2018-07-03
    # this should fix 56 files
    if [[ $file =~ .*2017.*_PP_EVT\.csv ||
          $file =~ .*2017.*_rep_partant_EVT\.csv ||
          $file =~ .*2017.*_rep_nouveau_modifie_EVT\.csv ||
          $file =~ .*20180703.*_actes\.csv ]]; then
      sed -i ':a;s/;"N;/;"N";/;ta' "$file"
    fi

    # force RFC4180 format for unconforming but parseable files
    # between 2017-05-12 and 2018-02-03
    # requires perl and Text::CSV_XS v>=1.29 (warning Text::CSV_PP might be too lax)
    # requires GNU awk v>=4.1.0 (for the new inplace option)
    # this should fix 9430 files
    if [[ $file =~ .*2017.*\.csv ||
          $file =~ .*201801.*\.csv ||
          $file =~ .*2018020[123].*\.csv ]]; then
      perl -MText::CSV -ne '
         BEGIN
         {$csv = Text::CSV->new(
            { sep_char => chr(59),
              quote_char => chr(34),
              escape_char => chr(34),
              binary => 1,
              strict => 1,
              auto_diag => 2,
              diag_verbose => 0 });}
         $csv->parse($_)' "$file" || \
      { perl -MText::CSV -ne '
         BEGIN
         {$csv = Text::CSV->new(
            { sep_char => chr(59),
              quote_char => chr(196),
              escape_char => chr(196),
              binary => 1,
              strict => 1,
              auto_diag => 2,
              diag_verbose => 0 });}
         $csv->parse($_)' "$file" && \
      awk -i inplace -v FS=';' -v OFS=';' '{
        for ( i=1; i<=NF; i++) {
          if ( $i ~ /[a-zA-Z]/ ) {
            gsub(/["]/,"",$i); $i="\"" $i "\""    # Remove dquotes, add them back.
            }
          }
        }1' "$file"; }
    fi

    # special case: guarding a few ungarded embedded double quotes
    if [[ $file =~ 9301_578_20180426_060039_6_rep_nouveau_modifie_EVT.csv ||
          $file =~ 5103_244_20180413_062946_6_rep_nouveau_modifie_EVT.csv ||
          $file =~ 91305_218_20180315_054206_6_rep_nouveau_modifie_EVT.csv ||
          $file =~ 5301_182_20180126_061912_9_ets_nouveau_modifie_EVT.csv ||
          $file =~ 2002_187_20180126_063640_9_ets_nouveau_modifie_EVT.csv ||
          $file =~ 0101_182_20180130_053127_9_ets_nouveau_modifie_EVT.csv ||
          $file =~ 1305_218_20180315_054206_6_rep_nouveau_modifie_EVT.csv ||
          $file =~ 3802_188_20180127_055646_8_ets.csv ||
          $file =~ 3302_377_20180130_065947_8_ets.csv ]]; then
      sed -i -E 's/;([^";]+)"([^";]+)";/;"\1""\2""";/' "$file"
    fi
    if [[ $file =~ 4901_192_20180130_063155_9_ets_nouveau_modifie_EVT.csv ]]; then
      sed -i -E 's/;"([^";]+)"([^";]+);/;"""\1""\2";/' "$file"
    fi
    if [[ $file =~ 6002_444_20180331_055404_3_PP.csv ||
          $file =~ 6002_450_20180408_091314_3_PP.csv ||
          $file =~ 6002_455_20180410_061903_3_PP.csv ||
          $file =~ 4101_193_20180126_055813_8_ets.csv ||
          $file =~ 9301_404_20180130_061441_8_ets.csv ]]; then
       sed -i -E 's/;([^";]+)"([^";]+)"([^";]+);/;"\1""\2""\3";/' "$file"
     fi

     # special case: clean the /; ";/ in 3405_180_20180103_093457_11_obs.csv
     if [[ $file =~ 3405_180_20180103_093457_11_obs.csv ]]; then
       sed -i '23,24s/; ";/;;/' "$file"
     fi

     # special case: bogus file with wrong number of fields
     if [[ $file =~ 1402_580_20190306_091648_5_rep.csv ]]; then
       sed -i 's/;supprimé;supprimé;supprimé;supprimé;supprimé;/;supprimé;supprimé;supprimé;supprimé;/' "$file"
     fi

     # special case: bogus empty files with a blank line
     if [[ $file =~ 5201_353_20181009_084321_4_PP_EVT.csv ||
         $file =~ 5201_353_20181009_084321_7_rep_partant_EVT.csv ]]; then
       sed -i '2 d' "$file"
     fi

    # special case: tc/flux/2017/09/28/1303/197/1303_197_20170928_074405_9_ets_nouveau_modifie_EVT.csv
    # this one is RFC4180 compliant but the content seems bogus (fields misalignement)

    # Fixing the line breaks
    # | Each record is located on a separate line, delimited by a line break (CRLF)
    # source: https://tools.ietf.org/html/rfc4180#section-2
    # this should touch all files (1224230 at the time of writing)
    LANG=C LC_ALL=C sed -i -E 's/([^\r])$/\1\r/g' "$file"
  fi

  # Dealing with 20180824 partial stock
  if [[ $file =~ .*_S2_20180824\.zip ]]; then
    ### Partial stocks extraction ###
    #################################
    # Get the directory path containing the partial stock
    file_path=$(dirname $file)

    # Get the filename without the extension, the name is used as
    # subfolder for the extracted files
    filename=$(basename $file | sed s/\.zip$//)
    extraction_path=$file_path/$filename
    mkdir -p $extraction_path

    unzip -q $file -d $extraction_path

    ### Cleaning CSV ###
    ####################
    for stock_file in $extraction_path/*.csv; do
      # Fixing errors appearing in rep files in the 24/08/2018 partial stock
      if [[ $stock_file =~ .*_5_rep\.csv ]]; then
        # remove blank spaces surrounding fields when quotes are specified
        # Eg: ... ;  "coucou" ; ... => ... ;"coucou"; ...
        sed -i -E 's/;[[:blank:]]+"(.*)"[[:blank:]]+;/;"\1";/' "$stock_file"

        # Escape surrounding double quotes inside an unquoted field
        # Eg: ... ;coucou "lol" yo; ... => ... ;"coucou ""lol"" yo"; ...
        sed -i -E 's/;([^";]+)"([^";]+)"([^";]+);/;"\1""\2""\3";/' "$stock_file"
      fi
    done

    ### ZIP files after cleaning ###
    ################################
    zip -q -r -j $file $extraction_path

    ### Delete temporary extraction folder ###
    ##########################################
    rm -rf $extraction_path
  fi
done
