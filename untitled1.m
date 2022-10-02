clc;
clear;

%importy
B216in_AR09 = importdata("R23_LR315_216in_AR_9,34_T1-12_0 m_s-VLM2.txt");
B216in_AR10 = importdata("R23_LR315_216in_AR_10,65_T1-12_0 m_s-VLM2.txt");
B216in_AR12 = importdata("R23_LR315_216in_AR_12,01_T1-12_0 m_s-VLM2.txt");
B216in_AR13 = importdata("R23_LR315_216in_AR_13,03_T1-12_0 m_s-VLM2.txt");
B192in_AR12 = importdata("R23_LR315_192n_AR_12,00_T1-12_0 m_s-VLM2.txt");
B192in_AR10 = importdata("R23_LR315_192in_AR_10,06_T1-12_0 m_s-VLM2.txt");
B192in_AR08 = importdata('R23_LR315_192in_AR_8,46_T1-12_0 m_s-VLM2.txt');
B168in_AR11 = importdata('R23_LR315_168in_AR_11,08_T1-12_0 m_s-VLM2.txt');
B168in_AR09 = importdata('R23_LR315_168in_AR_9,34_T1-12_0 m_s-VLM2.txt');
B168in_AR08 = importdata ('R23_LR315_168in_AR_8,06_T1-12_0 m_s-VLM2.txt');
B120in_AR07 = importdata ('R23_LR315_120in_AR7,99_T1-12_0 m_s-VLM2.txt');
B120in_AR06 = importdata ('R23_LR315_120in_AR_6,53_T1-12_0 m_s-VLM2.txt');
B120in_AR05 = importdata ('R23_LR315_120in_AR_5,53_T1-12_0 m_s-VLM2.txt');
Ciag= importdata('Charakterystyki ciagu.xlsx');
geometric_data=importdata('geometric_data.xlsx');
s(1)=B192in_AR10;
s(2)=B192in_AR08;
%dodawanie numerkow
B216in_AR09.number=21609;
B216in_AR10.number=21610;
B216in_AR12.number=21612;
B216in_AR13.number=21613;
B192in_AR08.number=19608;
B192in_AR10.number=19610;
B192in_AR12.number=19612;
B168in_AR08.number=16808;
B168in_AR09.number=16809;
B168in_AR11.number=16811;
B120in_AR05.number=12005;
B120in_AR06.number=12006;
B120in_AR07.number=12007;
%ladne nazywanie funkcji
B216in_AR09 = PROfunctions.naming_data(B216in_AR09);
B216in_AR10 = PROfunctions.naming_data(B216in_AR10);
B216in_AR12 = PROfunctions.naming_data(B216in_AR12);
B216in_AR13 = PROfunctions.naming_data(B216in_AR13);
B192in_AR08 = PROfunctions.naming_data(B192in_AR08);
B192in_AR10 = PROfunctions.naming_data(B192in_AR10);
B192in_AR12 = PROfunctions.naming_data(B192in_AR12);
B168in_AR08 = PROfunctions.naming_data(B168in_AR08);
B168in_AR11 = PROfunctions.naming_data(B168in_AR11);
B120in_AR05 = PROfunctions.naming_data(B120in_AR05);
B120in_AR06 = PROfunctions.naming_data(B120in_AR06);
B120in_AR07 = PROfunctions.naming_data(B120in_AR07);
%wprowadzenie geometrii
B216in_AR09 = PROfunctions.geo_data(B216in_AR09,geometric_data);
B216in_AR10 = PROfunctions.geo_data(B216in_AR10,geometric_data);
B216in_AR12 = PROfunctions.geo_data(B216in_AR12,geometric_data);
B216in_AR13 = PROfunctions.geo_data(B216in_AR13,geometric_data);
B192in_AR08 = PROfunctions.geo_data(B192in_AR08,geometric_data);
B192in_AR10 = PROfunctions.geo_data(B192in_AR10,geometric_data);
B192in_AR12 = PROfunctions.geo_data(B192in_AR12,geometric_data);
B168in_AR08 = PROfunctions.geo_data(B168in_AR08,geometric_data);
B168in_AR09 = PROfunctions.geo_data(B168in_AR09,geometric_data);
B168in_AR11 = PROfunctions.geo_data(B168in_AR11,geometric_data);
B120in_AR05 = PROfunctions.geo_data(B120in_AR05,geometric_data);
B120in_AR06 = PROfunctions.geo_data(B120in_AR06,geometric_data);
B120in_AR07 = PROfunctions.geo_data(B120in_AR07,geometric_data);
%katy zaklinowania
%dane
FFS=[];
mi=0.04;
B216in_AR09 =PROfunctions.minimum_Rx(B216in_AR09,table2array(B216in_AR09.data),mi);
B216in_AR09 = PROfunctions.optimum(B216in_AR09,table2array(B216in_AR09.data),Ciag);
B216in_AR09=PROfunctions.start_anal(B216in_AR09,table2array(B216in_AR09.data),Ciag,mi);
B216in_AR09=PROfunctions.final_points(B216in_AR09);
FFS= PROfunctions.compare_points(B216in_AR09,FFS);




