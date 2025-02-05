#!/bin/bash

# Build python packages with setup.py
# This section builds all the feature packages implemented in
# python. It searches for all folders that contains setup.py
#


while read line
do
    # check out a specific directory from the master branch
    setup_files=(`find ./$line -type f -name 'setup.py'`);
    dist_dir=$( cd $(dirname $0) ; pwd -P )

    #array=( ${array[@]} $line )
    #echo ${array[@]}
# A list of the integration packages which has known good tests and can be included in the build. 
# Eventually all integrations should be in the build and this should be removed 
# It is used at the moment to ensure all packages built are ones with working tests.
done <<EOM
fn_task_utils
EOM

echo "Building these packages:";
printf '  %s\n' "${setup_files[@]}";
echo "Storing packages to: $dist_dir";
for setup in ${setup_files[@]};
do
    # Run the Build
    pkg_dir=$(dirname "${setup}")
    echo "Running build from $pkg_dir";
    (cd $pkg_dir && python setup.py -q sdist --dist-dir $dist_dir);
done;

# Build content packages with resilient-res-package.sh
# This section builds all the content/resource only package. No setup.py
# It searches for a script called resilient-res-package.sh, and calls it.
# Most likely you only need to zip some files folders. Follow the example
# in the ../res_qraw_mitre folder.

build_scripts=(`find .. -type f -name 'resilient-res-package.sh'`);

echo "Building these content packages:";
printf '  %s\n' "${build_scripts[@]}";
echo "Storing packages to: $dist_dir";
for res_folder in ${build_scripts[@]};
do
    # Run the Build
    pkg_dir=$(dirname "${res_folder}")
    pushd $pkg_dir
    ./resilient-res-package.sh $dist_dir;
    popd
done;
