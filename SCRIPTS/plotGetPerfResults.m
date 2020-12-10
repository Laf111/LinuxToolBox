%************************************************************************%
% Project: Exe-CSO                                                       %
% File:    tracePerf.m                                                   %
% Author:  THALES                                                        %
%                                                                        %
% Role:    Plot memory and CPU load form a global.perf file              %
% Input:   gpFilepath (char string): global.perf full file path          %
%************************************************************************% 
% HISTORIQUE
% VERSION::FA:<num_ft>:<date>:[<commentaire libre>]
% VERSION::DM:<num_ft>:<date>:[<commentaire libre>]
% FIN-HISTORIQUE
%************************************************************************%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL FUNCTIONS                                                               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function outData = getXMLLineData(line, tag, prevData)
%    if strfind(line, ['<', tag, '>'])
%        % strtrim is necessary to make strtok work correctly here
%        [~, tmpToken] = strtok(strtrim(line), '<>');
%        outData = strtok(tmpToken, '<>');
%    else
%        outData = prevData;
%    end
%end % end function getXMLLineData

%end % end function




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN PRGOGRAM                                                                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

workingDirFullPath='/data/CSO/WORK_FAU/TQ_OUTPUT/production_N2-ORTHO_CLIOV2_TLS_StereoJour_ZIG_MntDTED2_RecORTHO2_Rejeu_PAn-PXS-IR';

perfFolder=[ workingDirFullPath '/execution/perf_logs/' ];

gpFilepath=[ perfFolder 'global.perf' ]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Load Reslults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

curLine = '';
timeLine = [];
cpu = [];
mem = [];
ioRead = [];
ioWrite = [];
ior_virt = [];
iow_virt = [];

% global.perf line format : 
% delayFromStart totalCpuLoad totalMemory(Mo) memoryLoad(Ko) ioRead(Byte) ioWrite(Byte) ior_virt(Byte) iow_virt(Byte)

% Open file
currentFile = fopen(gpFilepath, 'r');
i=1;
if currentFile ~= -1
    curLine = fgetl(currentFile);
    while(ischar(curLine))
        if ~isempty(curLine)
            if isempty(strfind(curLine, '#'))
                array=sscanf(curLine, '%f');
                if (length(array) == 8)
                    timeLine=[timeLine array(1)];
                    cpu = [cpu array(2)];
                    mem = [mem array(3)];
                    ioRead = [ioRead array(5)/1000000.0];
                    ioWrite = [ioWrite array(6)/1000000.0];
                    ior_virt = [ior_virt array(7)/1000000.0];
                    iow_virt = [iow_virt array(8)/1000000.0];
                    
               end
            end
            if ~isempty(strfind(curLine, '# total io_real_read(Mo)='))
                ioReadMax = str2num(strtok(curLine, '# total io_real_read(Mo)='));
            end
            if ~isempty(strfind(curLine, '# total io_realwrite(Mo)='))
                ioWriteMax = str2num(strtok(curLine, '# total io_realwrite(Mo)='));
            end
            if ~isempty(strfind(curLine, '# total io_virt_read(Mo)='))
                ior_virtMax = str2num(strtok(curLine, '# total io_virt_read(Mo)='));
            end
            if ~isempty(strfind(curLine, '# total io_virt_write(Mo)='))
                iow_virtMax = str2num(strtok(curLine, '# total io_virt_write(Mo)='));
            end
        end

        curLine = fgetl(currentFile);
        i=i+1;
        
    end

    % Close file
    fclose(currentFile);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Reslults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbPts=length(timeLine);
f=figure('Name',[ 'Global performances from ' gpFilepath ],'NumberTitle','off');

a1=subplot(3,1,1);
set(gca,'xtick',[])
p1=plot(timeLine, cpu,'LineWidth',2);

p1Legend=[ 'Total CPU Load'];
legend(p1, p1Legend);

a2=subplot(3,1,2);
set(gca,'xtick',[])
p2=plot(timeLine, mem, 'r','LineWidth',2);

p2Legend=[ 'Total memory Load (Mo)'];
legend(p2, p2Legend);


a3=subplot(3,1,3);
set(gca,'xtick',[])

ior(1:nbPts)=ioReadMax;
iow(1:nbPts)=ioWriteMax;
vior(1:nbPts)=ior_virtMax;
viow(1:nbPts)=iow_virtMax;
p3=plot(timeLine, ior, '--r', ...
        timeLine, iow, 'r', ...
        timeLine, vior,':m', ...
        timeLine, viow, '-.m','LineWidth',2);
legend(p3, 'Max IO read (Mo)', 'Max IO write (Mo)', 'Max virtual IO read (Mo)', 'Max virtual IO write (Mo)');
hold on;

% setting x axis label
xlabel('temps en secondes');

% setting last to first (initializing)
lastIoRead=ioRead(1);
lastIoWrite=ioWrite(1);
lastIor_virt=ior_virt(1);
lastIow_virt=iow_virt(1);


list=ls([perfFolder 'pid*.perf']);
cellExeFiles=strsplit(list);

lastExeName='';
nbInstances=1;

color=rand(1,3);

for i=1:length(cellExeFiles)
    exeLogPerfFile=char(cellExeFiles(i));
    
    if (~isempty(exeLogPerfFile))
        % getting file name
        cut=strsplit(exeLogPerfFile,'/');
        fileName=char(cut(length(cut)));
        
        
        % getting Exe
        cut=strsplit(fileName,'_');
        exeName=char(cut(6));

        if ( ~strcmp(lastExeName, exeName) )

            % log for last exe handled
            
            if (strcmp(lastExeName, ''))
                exe=exeName;
                lastExeName=exeName;

            else
                exe=lastExeName;

                msg = sprintf('%s : color [%f, %f, %f]', exe, color(1,1), color(1,2), color(1,3));
                disp(msg);
                msg = sprintf(' -> %d instances launched ', nbInstances);
                disp(msg);

                lastExeName=exeName;
                color=rand(1,3);
                nbInstances=1;
            end

        else
            nbInstances=nbInstances+1;
        end
            
        % Open file
        
        curLine = '';
        clear timeLine
        timeLine = [];
        clear cpu
        cpu = [];
        clear mem
        mem = [];
        
        if (~isempty(ioRead))
            lastIoRead=ioRead(length(ioRead));
        end
        clear ioRead
        ioRead = [];
        if (~isempty(ioWrite))
            lastIoWrite=ioWrite(length(ioWrite));
        end
        clear ioWrite
        ioWrite = [];
        
        if (~isempty(ior_virt))
            lastIor_virt=ior_virt(length(ior_virt));
        end
        clear ior_virt
        ior_virt = [];

        if (~isempty(iow_virt))
            lastIow_virt=iow_virt(length(iow_virt));
        end
        clear iow_virt
        iow_virt = [];
        
        currentFile = fopen(exeLogPerfFile, 'r');
        j=1;
        if currentFile ~= -1
            curLine = fgetl(currentFile);
            while(ischar(curLine))
                if ~isempty(curLine)
                    if isempty(strfind(curLine, '#'))
                        array=sscanf(curLine, '%f');
                        if (length(array) == 8)
                            timeLine=[timeLine array(1)];
                            cpu = [cpu array(3)];
                            mem = [mem array(4)/1000.0];
                            ioRead = [ioRead (array(5)/1000000.0 + lastIoRead)];
                            ioWrite = [ioWrite (array(6)/1000000.0 + lastIoWrite)];
                            ior_virt = [ior_virt (array(7)/1000000.0 + lastIor_virt)];
                            iow_virt = [iow_virt (array(8)/1000000.0 + lastIow_virt)];
                        end
                    end
                    
                end

                curLine = fgetl(currentFile);
                j=j+1;
                
            end

            % Close file
            fclose(currentFile);
            
            
            % plot on cpu axis
            axes(a1);
            hold on;
            plot(timeLine, cpu, 'DisplayName', exeLogPerfFile, 'Color', color);

            axes(a2);
            hold on;
            plot(timeLine, mem, 'DisplayName', exeLogPerfFile, 'Color', color);
            
            axes(a3);
            hold on;
            plot(timeLine, ioRead, '--', 'Color', color, 'DisplayName', exeLogPerfFile);
            plot(timeLine, ioWrite, 'Color', color, 'DisplayName', exeLogPerfFile);
            plot(timeLine, ior_virt, ':', 'Color', color, 'DisplayName', exeLogPerfFile);
            plot(timeLine, iow_virt, '-.', 'Color', color, 'DisplayName', exeLogPerfFile);
            hold off;
            
        end
        
        
        
        
    end
    
end

msg = sprintf('%d instances launched of %s, plotted with color [%f, %f, %f]', nbInstances, exeName, color(1,1), color(1,2), color(1,3));
disp(msg);



