function checksum = ejp_checksum(filename)

    % فایل را باینری باز می‌کنیم
    fid = fopen('E:\871 با درصد.ejp', 'rb');
    if fid < 0
        error('Cannot open file.');
    end

    % همه بایت‌ها را می‌خوانیم
    data = fread(fid, inf, 'uint8');
    fclose(fid);

    % دو بایت آخر چک‌سام هستند → آن‌ها را حذف می‌کنیم
    data_without_checksum = data(1:end-2);

    % چک‌سام: مجموع بایت‌ها مود 65536
    checksum_val = mod(sum(data_without_checksum), 65536);

    % تبدیل به Little-Endian
    low  = bitand(checksum_val, 255);
    high = bitshift(checksum_val, -8);

    checksum = uint8([low, high]);

    % نمایش نتیجه
    fprintf("Checksum (hex): %02X %02X\n", checksum(1), checksum(2));
end
