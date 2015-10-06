function cubeCutout(token, channel, queryFile, outputFile, useSemaphore, objectType, serviceLocation)
    % cubeCutout function allows the user to post raw annotation data (i.e.
    % no meta data) in the form of either annotation labels or probabilities to
    % OCP.
    %
    % **Inputs**
    %
    %	:token: [string]   OCP token name serving as the source for data
    %
    %   :channel: [string] OCP channel name for source data
    %
    %	:queryFile: [string]    Fully formed OCP query saved to a .mat file
    %
    %   :outputFile: [string]  Output location of the returned cube from the query
    %
    %	:useSemaphore: [int][default=0]  throttles reading/writing client-side for large batch jobs.  Not needed in single cutout mode
    %
    %	:objectType: [int]  Flag indicating data download type. 0=RAMONVolume saved to .mat; 1=HDF5 saved to .h5
    %
    %	:serviceLocation: [string]   Location of OCP server hosting the
    %	data, typically openconnecto.me
    %
    %
    % **Outputs**
    %
    %	No explicit outputs.  Output cubes are saved to disk rather
    %	than output as a variable to allow for downstream integration with
    %	LONI.
    %

%cubeCutout - This function saves a file with the specified cube
    %   
    % The input is a OCPQuery that typically is generated by
    % cubeCutoutPreprocess.  
    %
    % This module can save the retrieved cube as either a RAMONVolume
    % (which is the default) stored in a .mat file or an HDF5 .h5 file by
    % setting the objectType flag.  If omitted a RAMONVolume is
    % created.
    %
    % 0 = RAMONVolume in .mat format
    % 1 = HDF5 dataset in .h5 format
    %

    %% Create data access object        
    if ~exist('useSemaphore','var')
        useSemaphore = false;
    end     
    if ~exist('objectType','var')
        objectType = 0;
    end    
    if ~exist('serviceLocation','var')
        serviceLocation = 'http://openconnecto.me/';
    end
    
    validateattributes(token,{'char'},{'row'});
    validateattributes(queryFile,{'char'},{'row'});    
    
    if useSemaphore == 1        
        oo = OCP('semaphore');
    else
        oo = OCP();
    end
    
    oo.setServerLocation(serviceLocation);
    oo.setImageToken(token);
    oo.setImageChannel(channel);
    
    %% Load Query
    queryObj = OCPQuery.open(queryFile);
       
    %% Get Data and save file
    
    cube = oo.query(queryObj); 
            
    switch objectType
        case 0
            save(outputFile,'cube');
        case 1                       
            % Save relevant "cutout" RAMONVolume fields to HDF5 file.
            % data, dataFormat, xyzOffset, resolution, etc.
            OCPHdf(cube,outputFile);
            
        otherwise            
            error('cubeCutout:DATAFORMATERROR','Invalid output type:%d',objectType);
    end

end

