# idhh-xsl
XSL code for transforming XML records harvested by the (Illinois Digital Heritage Hub)[https://idhh.dp.la], the (Digital Public Library of America)[https://dp.la] service hub for Illinois. Various templates perform the following operations on XML:

- Normalizes delimiters (e.g., replacing commas [','] with semicolons [';'])
- Creates EDM field for Intermediate Provider
- Creates DCTERMS field for Provider
- Creates EDM field for standardized rights for Creative Commons license URIs
- Splits coordinated subject values
- Refines language metadata:
  - Normalizes delimiters
  - Removes special characters
  - Matches most values to ISO 639 language names
- Refines format metadata:
  - Matches on both dc:format and dcterms:medium fields
  - Deletes commonly occurring irrelevant values
  - Creates dcterms:extent fields for some values
  - Matches most values to AAT format names
- Refines type metadata:
  - Normalizes delimiters
  - Deletes commonly occurring irrelevant values
  - Matches most values to DCMI type names

Written in XSL 2.0 using xpath 2.0.
