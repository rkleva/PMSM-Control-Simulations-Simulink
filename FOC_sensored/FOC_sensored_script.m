clc
clear
clear all


%% Encoder settings
Encoder_resolution = 4000;

%% Parametri SMPM-a
Udc = 24;                   % nazivni napon DC linka [V]
Udc_limit = 24/sqrt(3);
Un = 24/(sqrt(2)*sqrt(3));  % nazivni napon u [V]
In = 1;                     % nazivna struja u [A]
Pn = 3*Un*In;               % nazivna snaga u [W]
ns = 24000;                 % nazivna sinkrona brzina vrtnje u [o/min]
fs = 1600;                  % frekvencija statorskog polja u [Hz]                    
Psir = 0.0064;              % tok u [Wb]
Rs = 0.85/2;                % otpor statora u [Ohm]
Ls = 330e-6/2;              % iduktvitet statora u [H]
J = 0.1e-4;                 % moment inercije u [kg m^2]
D = 0.00001;                  % konstanta prigušenja [Nm s/rad] 

pp = (60*fs)/ns;             % broj pari polova [-]
nn = ns/pp;                  % mehanička nazivna brzina vrtnje u [o/min]
wn = nn * pi/30;
Mn = Pn/wn;

%% Parametri strukture upravljanja
K_q = 1/Rs;                 % statičko pojačanje električnog kruga u q-osi
tau_q = Ls/Rs;              % električna vremenska konstanta
K_w = (1.5*pp*Psir)/(2*D);    % statičko pojačanje električnog kruga
tau_w = J/D;

%% Pokazatelji kvalitete odziva
sigma = 0.05;                                                       % nadvišenje [-]
t2 = 3e-3;                                                          % vrijeme ustaljivanja [s]
zeta=abs(log(sigma)/(sqrt(pi^2+(log(sigma))^2)));                   % faktor prigušenja
omega_n = 4/t2/zeta;                                                % prirodna frekvencija
omega_bw = omega_n*sqrt((1-2*zeta^2)+sqrt(4*zeta^4-4*zeta^2+2));    % širina propusnosog pojasa u [rad/s]
f_bw = ceil(20*omega_bw/2/pi/1e3)*1e3;                              % širina propusnosog pojasa u [Hz]
Ts_max = 1/f_bw;                                                    % maskimalno vrijeme diskretizacije u [s]
Ts_max_round = round(Ts_max,1,'significant');

%% Kontinurirani PI regulator struje - metoda postavljanja polova
s = tf('s');
Kr_cont_current = (2*omega_n*tau_q*zeta - 1) / K_q;
Ti_cont_current = (2*omega_n*tau_q*zeta - 1) / (tau_q * omega_n^2);

G_filt_cont_current = 1/(Ti_cont_current*s+1);          % prefilter referentne vrijednosti
[G_filt_cont_num_current,G_filt_cont_den_current] = tfdata(G_filt_cont_current);
G_filt_cont_num_current = cell2mat(G_filt_cont_num_current);
G_filt_cont_den_current = cell2mat(G_filt_cont_den_current);

Gr_cont_current = Kr_cont_current*(1+1/(Ti_cont_current*s));
[Gr_cont_num_current,Gr_cont_den_current] = tfdata(Gr_cont_current);
Gr_cont_num_current = cell2mat(Gr_cont_num_current);
Gr_cont_den_current = cell2mat(Gr_cont_den_current);

%% Diskretni PI regulator struje - tehnika emulacije analognog PI regulatora
% promjenom Ts_current > Ts_max ili Ts < Ts_max dobivaju se ratličiti
% odzivi za različite tehnike diskretizacije
%Ts_current = 0.2*Ts_max;                      % vrijeme diskretizacije u [s]
Ts_current = 100e-6;
z = tf('z',Ts_current);                 % definicija diskretne kompleksne varijable z

% Prefilter - Forward Euler
G_filt_disc_emu_forw_current = 1/(Ti_cont_current*(z-1)/Ts_current+1); 
[G_filt_disc_emu_forw_num_current,G_filt_disc_emu_forw_den_current] = tfdata(G_filt_disc_emu_forw_current);
G_filt_disc_emu_forw_num_current = cell2mat(G_filt_disc_emu_forw_num_current);
G_filt_disc_emu_forw_den_current = cell2mat(G_filt_disc_emu_forw_den_current);

% Prefilter - Backward Euler
G_filt_disc_emu_back_current = 1/(Ti_cont_current*(z-1)/z/Ts_current+1); 
[G_filt_disc_emu_back_num_current,G_filt_disc_emu_back_den_current] = tfdata(G_filt_disc_emu_back_current);
G_filt_disc_emu_back_num_current = cell2mat(G_filt_disc_emu_back_num_current);
G_filt_disc_emu_back_den_current = cell2mat(G_filt_disc_emu_back_den_current);

% Prefilter - Tustin
G_filt_disc_emu_tustin_current = c2d(G_filt_cont_current,Ts_current,'tustin');
[G_filt_disc_emu_tustin_num_current,G_filt_disc_emu_tustin_den_current] = tfdata(G_filt_disc_emu_tustin_current);
G_filt_disc_emu_tustin_num_current = cell2mat(G_filt_disc_emu_tustin_num_current);
G_filt_disc_emu_tustin_den_current = cell2mat(G_filt_disc_emu_tustin_den_current);

%% Diskretni PI regulator struje - izravno postavljanje polova u z-ravnini
delta1 = -2*exp(-zeta*omega_n*Ts_current)*cos(omega_n*sqrt(1-zeta^2)*Ts_current);  % koeficijenti karakteristične jednadžbe diskretne prijenosne funckije drugog reda
delta2 = exp(-2*zeta*omega_n*Ts_current);

% Forward Euler - gains
Kr_direct_forw_current = (1+(1+delta1)*exp(Ts_current/tau_q)) / (K_q*(exp(Ts_current/tau_q)-1));
Ti_direct_forw_current = Ts_current * (1+delta1+exp(-Ts_current/tau_q)) / (1+delta1+delta2);
% Forward Euler - prefilter
G_filt_forw_current = 1/(Ti_direct_forw_current*(z-1)/Ts_current+1);
[G_filt_forw_num_current,G_filt_forw_den_current] = tfdata(G_filt_forw_current);
G_filt_forw_num_current = cell2mat(G_filt_forw_num_current);
G_filt_forw_den_current = cell2mat(G_filt_forw_den_current);

% Backward Euler - gains
Kr_direct_back_current = (1-delta2*exp(Ts_current/tau_q)) / (K_q*(exp(Ts_current/tau_q)-1));
Ti_direct_back_current = Ts_current * (exp(-Ts_current/tau_q)-delta2) / (1+delta1+delta2);
% Backward Euler - prefilter
G_filt_back_current = 1/(Ti_direct_back_current*(z-1)/Ts_current/z+1);
[G_filt_back_num_current,G_filt_back_den_current] = tfdata(G_filt_back_current);
G_filt_back_num_current = cell2mat(G_filt_back_num_current);
G_filt_back_den_current = cell2mat(G_filt_back_den_current);

% Tustin - gains
Kr_direct_tustin_current = (2-exp(Ts_current/tau_q)*(delta2-delta1-1)) / (2*K_q*(exp(Ts_current/tau_q)-1));
Ti_direct_tustin_current = Ts_current*(2*exp(-Ts_current/tau_q)+delta1-delta2+1) / (2*(1+delta1+delta2));
% Tustin - prefilter
G_filt_tustin_current = 1/(Ti_direct_tustin_current*s+1);
G_filt_tustin_current = c2d(G_filt_tustin_current,Ts_current,'tustin');
[G_filt_tustin_num_current,G_filt_tustin_den_current] = tfdata(G_filt_tustin_current);
G_filt_tustin_num_current = cell2mat(G_filt_tustin_num_current);
G_filt_tustin_den_current = cell2mat(G_filt_tustin_den_current);


%% Definicija željenih pokazatelja kvalitete prijelazne funckije brzine vrtnje
%t2_speed = round(0.2*J/D,4);                                                                     % vrijeme ustaljivanja
t2_speed = 100e-3;
sigma_speed = 0.05;                                                                              % maksimalno nadvišenje
zeta_speed = abs(log(sigma_speed)/(sqrt(pi^2+(log(sigma_speed))^2)));                            % faktor prigušenja
omega_n_speed = 4/zeta_speed/t2_speed;                                                           % prirodna frekvencija
omega_bw_speed = omega_n_speed*sqrt((1-2*zeta_speed^2)+sqrt(4*zeta_speed^4-4*zeta_speed^2+2));   % širina propusnosog pojasa u [rad/s]
f_bw_speed = ceil(20*omega_bw_speed/2/pi/1e3)*1e3;                                               % širina propusnosog pojasa u [Hz]
Ts_max_speed = 1/f_bw_speed;                                                                     % maskimalno vrijeme diskretizacije u [s]
Ts_max_speed_round = round(Ts_max_speed,1,'significant');

%% Kontinuirani PI regulator brzine vrtnje - metoda postavljanja polova
Kr_cont_speed = (2*omega_n_speed*tau_w*zeta_speed - 1) / K_w;           % izraz za propocionalno pojaèanje PI regulatora odreðeno metodom postavljanja polova
Ti_cont_speed = (2*omega_n_speed*tau_w*zeta_speed - 1) / (tau_w * omega_n_speed^2);   % izraz za integralnu vremensku konstantt PI regulatora odreðeno metodom postavljanja polova

G_filt_cont_speed = 1/(Ti_cont_speed*s+1);          % prefilter referentne vrijednosti
[G_filt_cont_num_speed,G_filt_cont_den_speed] = tfdata(G_filt_cont_speed);
G_filt_cont_num_speed = cell2mat(G_filt_cont_num_speed);
G_filt_cont_den_speed = cell2mat(G_filt_cont_den_speed);

Gr_cont_speed = Kr_cont_speed*(1+1/(Ti_cont_speed*s));
[Gr_cont_num_speed,Gr_cont_den_speed] = tfdata(Gr_cont_speed);
Gr_cont_num_speed = cell2mat(Gr_cont_num_speed);
Gr_cont_den_speed = cell2mat(Gr_cont_den_speed);

%% Diskretni PI regulator brzine vrtnje - tehnika emulacije analognog PI regulatora
Ts_speed = Ts_current;                             % vrijeme diskretizacije u [s]
%Ts_speed = 1e-3;
z = tf('z',Ts_speed);                              % definicija diskretne kompleksne varijable z


% Prefilter - Forward Euler
G_filt_disc_emu_forw_speed = 1/(Ti_cont_speed*(z-1)/Ts_speed+1); 
[G_filt_disc_emu_forw_num_speed,G_filt_disc_emu_forw_den_speed] = tfdata(G_filt_disc_emu_forw_speed);
G_filt_disc_emu_forw_num_speed = cell2mat(G_filt_disc_emu_forw_num_speed);
G_filt_disc_emu_forw_den_speed = cell2mat(G_filt_disc_emu_forw_den_speed);

% Prefilter - Backward Euler
G_filt_disc_emu_back_speed = 1/(Ti_cont_speed*(z-1)/z/Ts_speed+1); 
[G_filt_disc_emu_back_num_speed,G_filt_disc_emu_back_den_speed] = tfdata(G_filt_disc_emu_back_speed);
G_filt_disc_emu_back_num_speed = cell2mat(G_filt_disc_emu_back_num_speed);
G_filt_disc_emu_back_den_speed = cell2mat(G_filt_disc_emu_back_den_speed);

% Prefilter - Tustin
G_filt_disc_emu_tustin_speed = c2d(G_filt_cont_speed,Ts_speed,'tustin');
[G_filt_disc_emu_tustin_num_speed,G_filt_disc_emu_tustin_den_speed] = tfdata(G_filt_disc_emu_tustin_speed);
G_filt_disc_emu_tustin_num_speed = cell2mat(G_filt_disc_emu_tustin_num_speed);
G_filt_disc_emu_tustin_den_speed = cell2mat(G_filt_disc_emu_tustin_den_speed);

%% Diskretni PI regulator struje - izravno postavljanje polova u z-ravnini
delta1= -2*exp(-zeta_speed*omega_n_speed*Ts_speed)*cos(omega_n_speed*sqrt(1-zeta_speed^2)*Ts_speed);
delta2 = exp(-2*zeta_speed*omega_n_speed*Ts_speed);

% Forward Euler - gains
Kr_direct_forw_speed = (1+(1+delta1)*exp(Ts_speed/tau_w)) / (K_w*(exp(Ts_speed/tau_w)-1));
Ti_direct_forw_speed = Ts_speed * (1+delta1+exp(-Ts_speed/tau_w)) / (1+delta1+delta2);
% Forward Euler - prefilter
G_filt_forw_speed = 1/(Ti_direct_forw_speed*(z-1)/Ts_speed+1);
[G_filt_forw_num_speed,G_filt_forw_den_speed] = tfdata(G_filt_forw_speed);
G_filt_forw_num_speed = cell2mat(G_filt_forw_num_speed);
G_filt_forw_den_speed = cell2mat(G_filt_forw_den_speed);

% Backward Euler - gains
Kr_direct_back_speed = (1-delta2*exp(Ts_speed/tau_w)) / (K_w*(exp(Ts_speed/tau_w)-1));
Ti_direct_back_speed = Ts_speed * (exp(-Ts_speed/tau_w)-delta2) / (1+delta1+delta2);
% Backward Euler - prefilter
G_filt_back_speed = 1/(Ti_direct_back_speed*(z-1)/Ts_speed/z+1);
[G_filt_back_num_speed,G_filt_back_den_speed] = tfdata(G_filt_back_speed);
G_filt_back_num_speed = cell2mat(G_filt_back_num_speed);
G_filt_back_den_speed = cell2mat(G_filt_back_den_speed);

% Tustin - gains
Kr_direct_tustin_speed = (2-exp(Ts_speed/tau_w)*(delta2-delta1-1)) / (2*K_w*(exp(Ts_speed/tau_w)-1));
Ti_direct_tustin_speed = Ts_speed*(2*exp(-Ts_speed/tau_w)+delta1-delta2+1) / (2*(1+delta1+delta2));
% Tustin - prefilter
G_filt_tustin_speed = 1/(Ti_direct_tustin_speed*s+1);
G_filt_tustin_speed = c2d(G_filt_tustin_speed,Ts_speed,'tustin');
[G_filt_tustin_num_speed,G_filt_tustin_den_speed] = tfdata(G_filt_tustin_speed);
G_filt_tustin_num_speed = cell2mat(G_filt_tustin_num_speed);
G_filt_tustin_den_speed = cell2mat(G_filt_tustin_den_speed);

%% Cutoff frequency for speed feedback
T_speed_feedback = 0.0005;
