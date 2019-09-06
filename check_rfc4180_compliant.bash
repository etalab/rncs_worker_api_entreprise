#! /bin/bash

exvalue=0;

for file in "$@"; do
  if [ ! -f "$file" ]; then echo "The file does not exist" && break; fi
  if [ ! "${file##*.}" = "csv" ]; then echo "The file does not have a csv extension" &&
break; fi

   # check strict RFC4180 compliance
   # requires perl and Text::CSV_XS (warning Text::CSV_PP might be too lax)

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
       $csv->parse($_)' "$file" 2>/dev/null || { echo "$file is not RFC4180 compliant" &&
  exvalue=1; }

done
exit $exvalue;
