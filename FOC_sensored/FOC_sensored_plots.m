%% Clean publication-quality plot
clc; clear; close all;

%% Load data
data_current = load('Data/currents_iq_step.mat');
data_speed = load('Data/speeds_step.mat');

%% Number of samples
N_current = 65;
N_speed = 100000;

%% Time vectors
t_current = data_current.current_direct_backeuler.Time(1:N_current);
t_speed = data_speed.n_direct_backeuler.Time(1:N_speed);

%% Signals - current
iq_ref              = data_current.current_ref.Data(1:N_current);
iq_direct_back      = data_current.current_direct_backeuler.Data(1:N_current);
iq_direct_tustin    = data_current.current_direct_tustin.Data(1:N_current);
iq_emulation_back   = data_current.current_emulation_backeuler.Data(1:N_current);
iq_emulation_tustin = data_current.current_emulation_tustin.Data(1:N_current);

%% Signals - speed
n_ref              = data_speed.n_ref.Data(1:N_speed);
n_direct_back      = data_speed.n_direct_backeuler.Data(1:N_speed);
n_direct_tustin    = data_speed.n_direct_tustin.Data(1:N_speed);
n_emulation_back   = data_speed.n_emulation_backeuler.Data(1:N_speed);
n_emulation_tustin = data_speed.n_emulation_tustin.Data(1:N_speed);

%% Shared color palette
c_ref   = [0.20 0.20 0.20];   % dark slate gray
c_db    = [0.85 0.33 0.10];   % burnt orange
c_dt    = [0.00 0.45 0.70];   % steel blue
c_eb    = [0.00 0.55 0.35];   % teal green
c_et    = [0.55 0.30 0.65];   % muted purple

%% ===================== FIGURE 1: CURRENT =====================
fig1 = figure('Color','white','Units','pixels','Position',[100 100 800 420]);
ax1 = axes('Parent', fig1);
hold(ax1,'on'); box(ax1,'on'); grid(ax1,'on');

ax1.Color = 'white';
ax1.XColor = [0 0 0];
ax1.YColor = [0 0 0];
ax1.GridColor = [0.75 0.75 0.75];
ax1.GridAlpha = 0.6;
ax1.GridLineStyle = '--';
ax1.LineWidth = 0.9;
ax1.FontSize = 13;
ax1.TickLabelInterpreter = 'latex';

plot(t_current, iq_ref,              '-',  'LineWidth', 1.8, 'Color', c_ref);
plot(t_current, iq_direct_back,      '--', 'LineWidth', 1.4, 'Color', c_db);
plot(t_current, iq_direct_tustin,    ':',  'LineWidth', 1.8, 'Color', c_dt);
plot(t_current, iq_emulation_back,   '-.', 'LineWidth', 1.4, 'Color', c_eb);
plot(t_current, iq_emulation_tustin, '-',  'LineWidth', 1.2, 'Color', c_et);

xlabel('$t$ [s]', 'Interpreter','latex', 'FontSize',15);
ylabel('$i_q(t)$ [A]', 'Interpreter','latex', 'FontSize',15);

lgd1 = legend( ...
    '$i_{q,\mathrm{ref}}$', ...
    'Direct Backward Euler', ...
    'Direct Tustin', ...
    'Emulation Backward Euler', ...
    'Emulation Tustin');
set(lgd1, ...
    'Interpreter','latex', ...
    'FontSize',13, ...
    'Box','on', ...
    'Color','white', ...
    'EdgeColor',[0 0 0], ...
    'TextColor',[0 0 0], ...
    'Location','southeast');

xlim([t_current(1) t_current(end)]);

set(fig1, 'Renderer', 'painters');
set(fig1, 'InvertHardcopy', 'off');

exportgraphics(fig1, 'Plots/iq_current_blocked_rotor.pdf', ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white');

%% ===================== FIGURE 2: SPEED =====================
fig2 = figure('Color','white','Units','pixels','Position',[100 100 800 420]);
ax2 = axes('Parent', fig2);
hold(ax2,'on'); box(ax2,'on'); grid(ax2,'on');

ax2.Color = 'white';
ax2.XColor = [0 0 0];
ax2.YColor = [0 0 0];
ax2.GridColor = [0.75 0.75 0.75];
ax2.GridAlpha = 0.6;
ax2.GridLineStyle = '--';
ax2.LineWidth = 0.9;
ax2.FontSize = 13;
ax2.TickLabelInterpreter = 'latex';

plot(t_speed, n_ref,              '-',  'LineWidth', 1.8, 'Color', c_ref);
plot(t_speed, n_direct_back,      '--', 'LineWidth', 1.4, 'Color', c_db);
plot(t_speed, n_direct_tustin,    ':',  'LineWidth', 1.8, 'Color', c_dt);
plot(t_speed, n_emulation_back,   '-.', 'LineWidth', 1.4, 'Color', c_eb);
plot(t_speed, n_emulation_tustin, '-',  'LineWidth', 1.2, 'Color', c_et);

xlabel('$t$ [s]', 'Interpreter','latex', 'FontSize',15);
ylabel('$n(t)$ [rpm]', 'Interpreter','latex', 'FontSize',15);

lgd2 = legend( ...
    '$n_{\mathrm{ref}}$', ...
    'Direct Backward Euler', ...
    'Direct Tustin', ...
    'Emulation Backward Euler', ...
    'Emulation Tustin');
set(lgd2, ...
    'Interpreter','latex', ...
    'FontSize',13, ...
    'Box','on', ...
    'Color','white', ...
    'EdgeColor',[0 0 0], ...
    'TextColor',[0 0 0], ...
    'Location','southeast');

xlim([t_speed(1) t_speed(end)]);

set(fig2, 'Renderer', 'painters');
set(fig2, 'InvertHardcopy', 'off');

exportgraphics(fig2, 'Plots/n_speed_blocked_rotor.pdf', ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white');