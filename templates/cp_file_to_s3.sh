#!/bin/bash


if [ $# -lt 3 ]
then
    echo "$0 <source_filepath> <target_s3_bucket> <target_s3_prefix> <work_dir>"
    exit 1
fi
SOURCE_FILEPATH=$1
TARGET_S3_BUCKET=$2
TARGET_S3_PREFIX=$3
WORKDIR=${4:-/tmp}

echo "source filepath is $SOURCE_FILEPATH"
echo "target s3 bucket is $TARGET_S3_BUCKET"
echo "target s3 prefix is $TARGET_S3_PREFIX"
echo "workdir is $WORKDIR"

# get formatted last modification date
mod_date=$(stat "$SOURCE_FILEPATH" --format="%y" | awk -F"." '{print $1}' |  sed "s/ /T/g" | sed "s/://g")
target_backup_filename="${mod_date}_${target_filename}.gz"

if [ -z $mod_date ] || [ -z $target_filename ] || [ -z $target_dir ]
then
    echo "error formatting target backup filename"
    exit 1
fi

echo "backup filename is $target_backup_filename"

# compress file
gzip -c $SOURCE_FILEPATH > $WORKDIR/$target_backup_filename
if [ $? -ne 0 ]; then
    echo "error compressing: gzip -c $SOURCE_FILEPATH > $WORKDIR/$target_backup_filename"
    exit 1
fi

# copy to s3
# STANDARD_IA == infrequent access
aws s3 cp $WORKDIR/$target_backup_filename \
    s3://$TARGET_S3_BUCKET/$TARGET_S3_PREFIX/$target_backup_filename \
    --storage-class STANDARD_IA
if [ $? -ne 0 ]; then
    echo "error cp to s3:" \
         " aws s3 cp $WORKDIR/$target_backup_filename " \
         "s3://$TARGET_S3_BUCKET/$TARGET_S3_PREFIX/$target_backup_filename" \
         "--storage-class STANDARD_IA"
fi

# cleanup
rm $WORKDIR/$target_backup_filename
echo "cleaned up $WORKDIR/$target_backup_filename"

echo "$(date +"%F %T") copy to s3 DONE"

exit 0

