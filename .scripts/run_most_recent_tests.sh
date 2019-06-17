#!/bin/bash

# Search for the most recently edited integration folder. This integration will be the one that tests are ran against.
most_recent_package=$(ls -td ./*/ | head -1)
toxfiles=(`find $most_recent_package -type f -name 'tox.ini'`);

status=0;
for toxfile in ${toxfiles[@]};
do
    # Run the tests if current TOXENV is applicable for this tox.ini file
    valid_envs=`env -u TOXENV tox -c $toxfile --listenvs;`
    #echo "Supported Environments: $valid_envs" 
    if [[ "$valid_envs" =~ "$TOXENV" ]]
    then
        #TODO: remove explicit resilient args
        tox -c $toxfile -- tests;
        last_status=$?;
        if [ $last_status -ne 0 ]; then
            printf 'FAILURE %s: [%d]\n' $toxfile $last_status;
            status=$last_status;
        fi
    else
        printf 'Skipping %s because TOXENV %s incompatible\n' "$toxfile" "$TOXENV"
    fi
done;

printf 'Test Run Complete.  Final Status [%d]\n' $status;
exit $status

