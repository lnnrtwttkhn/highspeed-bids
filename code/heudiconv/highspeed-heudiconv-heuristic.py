#!/usr/bin/env python


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes


def infotodict(seqinfo):

    # paths in BIDS format
    anat = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_rec-{rec}_T1w')
    rest_pre = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_rec-{rec}_run-pre_bold')
    rest_post = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_rec-{rec}_run-post_bold')
    task = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-highspeed_rec-{rec}_run-{item:02d}_bold')
    fmap_topup = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_rec-{rec}_dir-{dir}_epi')
    info = {anat: [], rest_pre: [], rest_post: [], task: [], fmap_topup: []}

    for s in seqinfo:

        if 'NORM' in s.image_type:
            rec = 'prenorm'
        else:
            rec = 'nonorm'

        if ('t1' in s.series_description):
            info[anat].append({'item': s.series_id, 'rec': rec})
        if ('FM_' in s.series_description) and ('prenorm' in rec):
            info[fmap_topup].append({'item': s.series_id, 'rec': rec, 'dir': 'AP'})
        if ('FMInv_' in s.series_description) and ('prenorm' in rec):
            info[fmap_topup].append({'item': s.series_id, 'rec': rec, 'dir': 'PA'})
        if ('Rest_Pre' in s.series_description) and ('prenorm' in rec):
            info[rest_pre].append({'item': s.series_id, 'rec': rec})
        if ('Rest_Post' in s.series_description) and ('prenorm' in rec):
            info[rest_post].append({'item': s.series_id, 'rec': rec})
        # some participants have one post resting state labelled "Rest":
        if ('Rest' in s.series_description) and ('prenorm' in rec):
            info[rest_post].append({'item': s.series_id, 'rec': rec})
        if ('Run' in s.series_description) and ('prenorm' in rec):
            info[task].append({'item': s.series_id, 'rec': rec})

    return info
