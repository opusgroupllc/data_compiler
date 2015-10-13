# "Data Compiler" Application ReadMe:

## Description:

This is a partially functional mockup for a small business utilization dashboard.
﻿
﻿The dashboard is intended to help visualize the amount of small business spending as a percentage of the entire spending per agency (per each small business category)and show spending transactions over time to represent whether the goals were made early or late into the fiscal year.

While the goal is to eventually pull data directly from FPDS.gov, we are instead pulling via USASpending.gov for the time being.  This is due to the interest of time, because their API is easier to implement.

## Notes:
- **Small business determination:**
  - Pertaining to a particular NICS code - will be introduced at a later time.
- **Agency list issue:**
  - The data from USASpending.gov lists agency treasury codes. To populate the full drop-down list of treasury codes:
    - After researching, there does not seem to be an API available from which I can pull a list of agencies and their treasury codes. 
    - Therefore, I extracted the data from a PDF I retrieved from whitehouse.gov (https://www.whitehouse.gov/sites/default/files/omb/assets/a11_current_year/app_c.pdf) and loaded the data into database tables. This was a bit of extra work, as copying and pasting from a PDF table into another file results in each cell of each row being a new line of text.  Therefore I had to write some code to programmatically reformat the resulting text and build an insert statement to load the data into the database tables.
- **Other:**
  - This web site is still in beta, and is available only for testing and proof-of-concept. Data accuracy is not guaranteed at this stage of development.
  - The site works on mobile devices, but does not yet switch to a mobile-specific layout.
  - When pulling back a substantial amount of data, it will take some time for the data to be loaded and crunched.
  - A final color/layout scheme is yet to be decided on. 
