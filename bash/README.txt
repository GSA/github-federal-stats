run the process by typing the following:

     buildGitHubIndex.sh {TOKEN} {Configuration Reader Program} {Configuration File} {optional:refresh} {optional:agency or subagency}

where:

     {TOKEN} is a user GitHub token with the ability top read public repositories
     {Configuration Reader Program} should be set to where the "getConfigElement.sh" is located
     {Configuration File} should use either the one for all federal repositories or the one for an agency/subagency
     {refersh} indicates whether to update the data from GitHub or use what was previously retrieved
     {optional:agency or subagency} should specify the agency or subagency as denoted in the "GHOrgAgency.txt" under the "mapping" directory

If the provided config files are used, published output will be place under a corresponding agency folder in the "output/publish/" directory

Examples: 

     buildGitHubIndex.sh {key} ./control/getConfigElement.sh ./allConfig.txt true 
     will pull data for all the "U.S. Federal" entities self-identified on https://government.github.com/community/ and use the mapping file to look up the corresponding agency and subagency

     buildGitHubIndex.sh {key} ./control/getConfigElement.sh ./defaultConfig.txt true GSA
     will pull data for all the "U.S. Federal" entities self-identified on https://government.github.com/community/ and use the mapping file to look up the records corresponding to "GSA" as an agency

     buildGitHubIndex.sh {key} ./control/getConfigElement.sh ./defaultConfig.txt true "National Guard"
     will pull data for all the "U.S. Federal" entities self-identified on https://government.github.com/community/ and use the mapping file to look up the records corresponding to "National Guard" as a sub-agency

     Note: if you want to keep a log of the script output you can use IO redirection and tee.  For example:

     buildGitHubIndex.sh {key} ./control/getConfigElement.sh ./defaultConfig.txt true GSA 2>&1 | tee gsaoutput.log

Published Outputs:

     The index.html file can be opened to access the data published.