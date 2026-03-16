/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;
static const unsigned int borderpx         = 2;  /* Netlik için 2px idealdir */

/* Arka Plan: Koyu ve Derin Lacivert (Resimden daha pro hissettirir) */
static const float rootcolor[]             = COLOR(0x1a1b26ff); 

/* Pasif Pencere Kenarlığı: Arka planla uyumlu, dikkat dağıtmaz */
static const float bordercolor[]           = COLOR(0x24283bff); 

/* Aktif Pencere Kenarlığı: Odağını buraya toplar (Yumuşak Mavi) */
static const float focuscolor[]            = COLOR(0x7aa2f7ff); 

/* Acil Durum: Kritik uyarılar için */
static const float urgentcolor[]           = COLOR(0xbb9af7ff); 

/* Tam Ekran Arka Planı: Hafif bir siyah/gri geçişi */
static const float fullscreen_bg[]         = {0.1f, 0.1f, 0.1f, 1.0f};

/* tagging - TAGCOUNT must be no greater than 31 */
#define TAGCOUNT (9)

/* logging */
static int log_level = WLR_ERROR;


static const Rule rules[] = {
    /* app_id             title       tags mask     isfloating   monitor */
    { "Gimp",             NULL,       0,            1,           -1 },
    { "firefox",          NULL,       1 << 8,       0,           -1 },
    { "org.pwmt.zathura", NULL,       0,            1,           -1 }, 
    { "mpv",              "Webcam",   ~0,           1,           -1 }, 
    { "foot",             "Calculator", 0,          1,           -1 }, 

    /* Senin Özel Uygulama Dağılımın */
 /* Senin Özel Uygulama Dağılımın */
    { "foot",             NULL,       1 << 0,       0,           -1 }, /* Tag 1 */
    { "google-chrome",    NULL,       1 << 1,       0,           -1 }, /* Tag 2 */
    { "code",             NULL,       1 << 2,       0,           -1 }, /* Tag 3 */

    
/* Signal (Tag 4) */
    { "Signal",           NULL,       1 << 3,       0,           -1 }, 
    { "signal",           NULL,       1 << 3,       0,           -1 }, 
    
    /* Antigravity (Tag 5) */
    { "antigravity",      NULL,       1 << 4,       0,           -1 }, 
    { "Antigravity",      NULL,       1 << 4,       0,           -1 },
    { NULL,               "antigravity", 1 << 4,    0,           -1 },
    
    { "librewolf",        NULL,       1 << 5,       0,           -1 }, /* Tag 6 */
};

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* monitors */
/* (x=-1, y=-1) is reserved as an "autoconfigure" monitor position indicator
 * WARNING: negative values other than (-1, -1) cause problems with Xwayland clients due to
 * https://gitlab.freedesktop.org/xorg/xserver/-/issues/899 */
static const MonitorRule monrules[] = {
   /* name        mfact  nmaster scale layout       rotate/reflect                x    y
    * example of a HiDPI laptop monitor:
    { "eDP-1",    0.5f,  1,      2,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 }, */
	{ NULL,       0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
	/* default monitor rule: can be changed but cannot be eliminated; at least one monitor rule must exist */
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	/* example:
	.options = "ctrl:nocaps",
	*/
	.options = NULL,
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL
LIBINPUT_CONFIG_SCROLL_2FG
LIBINPUT_CONFIG_SCROLL_EDGE
LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE
LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;

/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* If you want to use the windows key for MODKEY, use WLR_MODIFIER_LOGO */
#define MODKEY WLR_MODIFIER_ALT

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }, \
{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_f, togglefullscreen, {0} }
/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* appearance ayarlarından sonra, keys[] dizisinden ÖNCE ekle */

/* commands */
/* wmenu: dmenu ruhu, Wayland hızı. */
static const char *menucmd[] = { 
    "wmenu-run", 
    "-N", "1a1b26", /* Normal Arka Plan */
    "-n", "7aa2f7", /* Normal Yazı */
    "-M", "7aa2f7", /* Master/Kenar Rengi */
    "-m", "1a1b26", /* Seçim Arka Plan */
    "-S", "7aa2f7", /* Seçili Arka Plan */
    "-s", "1a1b26", /* Seçili Yazı */
    NULL 
};
static const char *termcmd[] = { "foot", NULL };
/* Sway tarzı özel komutlar */
static const char *yazicmd[]  = { "foot", "--title=yazi_fm", "-e", "yazi", NULL };
static const char *btmcmd[]   = { "foot", "--title=Rust Monitor", "-e", "btm", NULL };
static const char *clipcmd[]  = { "sh", "-c", "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy", NULL };
/* DÜZELTİLDİ: Artık Mod+A doğrudan sistemdeki antigravity komutunu tetikleyecek */
static const char *anticmd[] = { "antigravity", NULL };
/* Donanım kontrolleri (Ses ve Parlaklık) */
static const char *volup[]    = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+", NULL };
static const char *voldown[]  = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-", NULL };
static const char *volmute[]  = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle", NULL };
static const char *monup[]    = { "brightnessctl", "set", "5%+", NULL };
static const char *mondown[]  = { "brightnessctl", "set", "5%-", NULL };


/* Application Commands */
static const char *chromecmd[]    = { "google-chrome-stable", NULL };
static const char *vscocmd[]      = { "code", NULL };
static const char *signalcmd[]    = { "signal-desktop", NULL };
static const char *librewolfcmd[] = { "librewolf", NULL };


/* TTY Geçiş Makrosu */
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }

static const Key keys[] = {
    /* modifier                     key                 function        argument */
    { MODKEY,                       XKB_KEY_d,          spawn,          {.v = menucmd} },
    { MODKEY,                       XKB_KEY_Return,     spawn,          {.v = termcmd} },
    
    /* Uygulama Kısayolları */
    { MODKEY,                       XKB_KEY_g,          spawn,          {.v = chromecmd} },
    { MODKEY,                       XKB_KEY_v,          spawn,          {.v = vscocmd} },
    { MODKEY,                       XKB_KEY_s,          spawn,          {.v = signalcmd} },
    { MODKEY,                       XKB_KEY_a,          spawn,          {.v = anticmd} },
    { MODKEY,                       XKB_KEY_w,          spawn,          {.v = librewolfcmd} },
    
    /* Sway Tarzı Diğer Araçlar */
    { MODKEY,                       XKB_KEY_y,          spawn,          {.v = yazicmd} },
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_b,          spawn,          {.v = btmcmd} },
    { MODKEY,                       XKB_KEY_p,          spawn,          {.v = clipcmd} },

    /* Hardware & Media */
    { 0, XKB_KEY_XF86AudioRaiseVolume,                  spawn,          {.v = volup} },
    { 0, XKB_KEY_XF86AudioLowerVolume,                  spawn,          {.v = voldown} },
    { 0, XKB_KEY_XF86AudioMute,                         spawn,          {.v = volmute} },
    { 0, XKB_KEY_XF86MonBrightnessUp,                   spawn,          {.v = monup} },
    { 0, XKB_KEY_XF86MonBrightnessDown,                 spawn,          {.v = mondown} },

    /* Ekran Alıntısı ve Diğerleri */
    { MODKEY,                       XKB_KEY_Print,      spawn,          SHCMD("grim -g \"$(slurp)\" - | swappy -f -") },
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_S,          spawn,          SHCMD("grim -g \"$(slurp)\" - | swappy -f -") },
    { MODKEY,                       XKB_KEY_n,          spawn,          SHCMD("pkill gammastep || gammastep -o -l 0:0 -t 1200:1200 -m wayland") },
    { MODKEY,                       XKB_KEY_c,          spawn,          SHCMD("foot --title=Calculator -e calc") },
    { MODKEY,                       XKB_KEY_x,          spawn,          SHCMD("mpv --title=Webcam --no-osc /dev/video0") },

    /* Pencere Yönetimi */
    { MODKEY,                       XKB_KEY_j,          focusstack,     {.i = +1} },
    { MODKEY,                       XKB_KEY_k,          focusstack,     {.i = -1} },
    { MODKEY,                       XKB_KEY_h,          setmfact,       {.f = -0.05f} },
    { MODKEY,                       XKB_KEY_l,          setmfact,       {.f = +0.05f} },
    { MODKEY,                       XKB_KEY_i,          incnmaster,     {.i = +1} },
    { MODKEY,                       XKB_KEY_space,      zoom,           {0} },
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_q,          killclient,     {0} },
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_e,          quit,           {0} },
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_space,      togglefloating, {0} },
    { MODKEY,                       XKB_KEY_t,          setlayout,      {.v = &layouts[0]} },
    { MODKEY,                       XKB_KEY_f,          setlayout,      {.v = &layouts[1]} },
    { MODKEY,                       XKB_KEY_m,          setlayout,      {.v = &layouts[2]} },
    { MODKEY,                       XKB_KEY_F8,         spawn,          SHCMD("sleep 0.1 && waylock") },
    { MODKEY,                       XKB_KEY_F7,         spawn,          SHCMD("~/.config/dwl/audio-toggle-profile.sh") },

    /* Monitör Kontrolleri */
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_F1,         spawn,          SHCMD("wlr-randr --output HDMI-A-1 --off --output eDP-1 --on") },
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_F2,         spawn,          SHCMD("wlr-randr --output eDP-1 --off --output HDMI-A-1 --on") },


/* Monitörler Arası Odak ve Pencere Taşıma */
    { MODKEY,                    XKB_KEY_comma,      focusmon,       {.i = WLR_DIRECTION_LEFT} },
    { MODKEY,                    XKB_KEY_period,     focusmon,       {.i = WLR_DIRECTION_RIGHT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,       tagmon,         {.i = WLR_DIRECTION_LEFT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,    tagmon,         {.i = WLR_DIRECTION_RIGHT} },

{ MODKEY,                    XKB_KEY_0,          view,           {.ui = ~0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright, tag,            {.ui = ~0} },

    /* Workspaces (TAGS) */
    TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                     0),
    TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                         1),
    TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                 2),
    TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                     3),
    TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                    4),
    TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                5),
    TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                  6),
    TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                   7),
    TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                  8),

    /* TTY Geçişleri */
    CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
    CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};




static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
