clc;
clear;

%% ===============================
%         USER INPUTS
% ===============================

input_ejp   = 'E:\3027.ejp';
output_ejp  = 'output.ejp';

new_percent = '30% wool';
new_country = 'iran order';

font_size   = 18;

%% ===============================
%     READ ORIGINAL EJP
% ===============================

fid = fopen(input_ejp,'rb');
data = fread(fid,inf,'uint8');
fclose(fid);

header_old = data(1:28);
checksum   = data(end-1:end);
img_data   = data(29:end-2);

%% ===============================
%   IMAGE DATA → BITMAP
% ===============================

bytes_per_row = 8;
n_rows = floor(length(img_data)/bytes_per_row);

img_matrix = zeros(n_rows,64);

for r = 1:n_rows
    for b = 1:8
        byte = img_data((r-1)*8+b);
        img_matrix(r,(b-1)*8+1:b*8) = de2bi(byte,8,'left-msb');
    end
end

%% ===============================
%  REPLACE TEXT REGIONS (KEY PART)
% ===============================
% نواحی تقریبی متن‌ها (قابل تنظیم دقیق)

percent_rows = 100:130;
country_rows = 150:180;

img_matrix(percent_rows,:) = ...
    render_text_to_bitmap(new_percent,64,length(percent_rows),font_size);

img_matrix(country_rows,:) = ...
    render_text_to_bitmap(new_country,64,length(country_rows),font_size);

%% ===============================
%  BITMAP → IMAGE DATA
% ===============================

new_img_data = zeros(n_rows*8,1,'uint8');

for r = 1:n_rows
    for b = 1:8
        bits = img_matrix(r,(b-1)*8+1:b*8);
        new_img_data((r-1)*8+b) = bi2de(bits,'left-msb');
    end
end

% ===============================
%% ===============================
%       BUILD CORRECT HEADER
% ===============================

header = zeros(28,1,'uint8');

% bytes 1–8 : job name (ASCII, space padded)
job_name ='2020'
name_bytes = uint8(job_name);
header(1:8) = uint8(32);   % space
header(1:min(8,length(name_bytes))) = name_bytes(1:min(8,end));

% bytes 9–16 : fixed
header(9:16) = uint8([40 00 08 05 00 00 00 00]);

% byte 17 : image height (number of rows)
header(17) = uint8(n_rows);

% bytes 18–20 : fixed
header(18:20) = uint8([06 08 00]);

% bytes 21–28 : ELTEX UK
header(21:28) = uint8('ELTEX UK');


%% ===============================
%       WRITE FINAL EJP
% ===============================

fid = fopen(output_ejp,'wb');
fwrite(fid,header,'uint8');
fwrite(fid,new_img_data,'uint8');
fwrite(fid,checksum,'uint8');   % همان checksum قبلی
fclose(fid);

disp('EJP modified successfully');




