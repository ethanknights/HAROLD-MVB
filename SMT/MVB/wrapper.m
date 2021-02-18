%Purpose:
%Run MVB for Action vs Baseline in SMT Task

%==========================================================================
%  Dir Setup - Do Once
%==========================================================================
%-SPM betas-%
% mkdir data
% cd data
% !lndir.sh /imaging/ek03/projects/HAROLD/SMT/pp/data/firstLevelModel ./
%-subInfo-%
% cd ../
% !cp /imaging/ek03/projects/HAROLD/SMT/pp/CCIDList.mat ./
%
%-ROIs-%
% !cp /imaging/ek03/projects/HAROLD/SMT/pp/*.nii ./
%
%
%-Restart analysis -%
% !rm -vvf data/CC*/MVB_*
% !rm -vvf data/CC*/*.ps

%==========================================================================
%  Paths/Var Setup
%==========================================================================

clear

spmDir = '/imaging/ek03/toolbox/SPM12_v7219';
if any(ismember(regexp(path,pathsep,'Split'),spmDir)); else; addpath(spmDir);
  spm('Defaults','fMRI'); spm_jobman('initcfg'); end 


% delete(gcp('nocreate')) %removes a previously active pool
% NumWorkers = 16;
% P = cbupool(NumWorkers);
% P.SubmitArguments = sprintf('--ntasks=%d --mem-per-cpu=4G --time=72:00:00',NumWorkers);
% parpool(P,NumWorkers)


load('CCIDList.mat','CCIDList')

done_createXYZ = 1;
done_MVB = 0;

%==========================================================================
% Setup ROIs
%==========================================================================
%--------- Roi pairs to work with (L/R)  ----------%
roifN = {'PreCG_L_70.nii',              ... %SMT Group ROI Action > Basesline
         'PreCG_R_70.nii',              ... %SMT L_70 Flipped
         'PreCG_L_35.nii',              ... %To control voxel size for ordy (35+35 = 70)
         'PreCG_R_35.nii',              ... %^^
%          'PreCG_L_140.nii',              ... %To control voxel size for ordy (70+70 = 140)
%          '',                              ... %^^ (skipping - comment loop/combine)
};
roiName = cellfun(@(x) x(1:end-4), roifN, 'Uniform', 0);  %cut '.nii'
roiPairs = [1,2;3,4]; %[1,2;3,4]; %etc

if ~done_createXYZ
  camcan_main_mvb_makexyz
end

%==========================================================================
% Run MVB
%==========================================================================
conditions = {'Action-Baseline'}; %A name of contrast in a con image
contrasts = [1]; %the corresponding con image number
model = 'sparse';

if ~done_MVB
  for r = 1:size(roiPairs,1) %rows
    for c = 1:length(contrasts)
    
    
      currROIs{1} = roiName{roiPairs(r,1)}; %LH
      currROIs{2} = roiName{roiPairs(r,2)}; %RH
      conditionName = conditions{c};
      con = contrasts(c);
    

    camcan_main_mvb_top(currROIs,conditionName,con,CCIDList,model);
          %tmp_controlVoxelSize_camcan_main_mvb_top(currROIs,conditionName,con,CCIDList,model);
    end
  end
end

return

%==========================================================================
% PostProcessing 
%==========================================================================
%  edit doPostProcessing.m

