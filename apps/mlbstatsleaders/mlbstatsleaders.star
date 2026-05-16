"""
Applet: MLB Stats Leaders
Summary: Displays MLB Stats Leaders
Description: View up to 10 leader stats for the current year. Choose from 30 available stats. Set rotation speed.
Author: symm512
"""

load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

TEAM_COLORS = {
    "ARI": "#A71930",
    "ATL": "#132448",
    "BAL": "#DF4601",
    "BOS": "#BD3039",
    "CHC": "#0E3386",
    "CWS": "#222222",
    "CIN": "#C6011F",
    "CLE": "#00385D",
    "COL": "#33006F",
    "DET": "#0C2340",
    "HOU": "#002D62",
    "KCR": "#004687",
    "LAA": "#BA0021",
    "LAD": "#005A9C",
    "MIA": "#1F1F1F",
    "MIL": "#1F4E79",
    "MIN": "#002B5C",
    "NYM": "#FF5910",
    "NYY": "#0A193B",
    "ATH": "#004B3F",
    "PHI": "#E81828",
    "SD": "#2F241D",
    "PIT": "#2F2F2F",
    "SEA": "#008080",
    "SF": "#FD5A1E",
    "STL": "#C41E3A",
    "TB": "#092C5C",
    "TEX": "#003278",
    "TOR": "#1A5BBF",
    "WSH": "#AB0003",
}

TEAM_TEXT_COLORS = {
    "ARI": "#FFD1D8",
    "ATL": "#CE1141",
    "BAL": "#FFFFFF",
    "BOS": "#FFE0E2",
    "CHC": "#B7D0FF",
    "CWS": "#FFFFFF",
    "CIN": "#FFD0D6",
    "CLE": "#E31937",
    "COL": "#E6D6FF",
    "DET": "#B9CFFF",
    "HOU": "#FF6600",
    "KCR": "#C2DDFF",
    "LAA": "#FFD0D0",
    "LAD": "#FFFFFF",
    "MIA": "#00A3E0",
    "MIL": "#FFC72C",
    "MIN": "#FF3B3B",
    "NYM": "#FFE2D6",
    "NYY": "#FFFFFF",
    "ATH": "#F5C542",
    "PHI": "#FFFFFF",
    "PIT": "#FDB827",
    "SD": "#D6CEC7",
    "SEA": "#FFFFFF",
    "SF": "#FFE1C9",
    "STL": "#FFD0D6",
    "TB": "#BFD6FF",
    "TEX": "#BFD6FF",
    "TOR": "#FFFFFF",
    "WSH": "#DCDCDC",
}

DEFAULT_COLOR = "#333333"
DEFAULT_TEXT = "#FFFFFF"

TEAM_NAME_MAP = {
    "Arizona Diamondbacks": "ARI",
    "Atlanta Braves": "ATL",
    "Baltimore Orioles": "BAL",
    "Boston Red Sox": "BOS",
    "Chicago Cubs": "CHC",
    "Chicago White Sox": "CWS",
    "Cincinnati Reds": "CIN",
    "Cleveland Guardians": "CLE",
    "Colorado Rockies": "COL",
    "Detroit Tigers": "DET",
    "Houston Astros": "HOU",
    "Kansas City Royals": "KCR",
    "Los Angeles Angels": "LAA",
    "Los Angeles Dodgers": "LAD",
    "Miami Marlins": "MIA",
    "Milwaukee Brewers": "MIL",
    "Minnesota Twins": "MIN",
    "New York Mets": "NYM",
    "New York Yankees": "NYY",
    "Athletics": "ATH",
    "Philadelphia Phillies": "PHI",
    "Pittsburgh Pirates": "PIT",
    "San Diego Padres": "SD",
    "Seattle Mariners": "SEA",
    "San Francisco Giants": "SF",
    "St. Louis Cardinals": "STL",
    "Tampa Bay Rays": "TB",
    "Texas Rangers": "TEX",
    "Toronto Blue Jays": "TOR",
    "Washington Nationals": "WSH",
}

STAT_CONFIG = {
    "None": {"api": "NoneNada", "title": "NO LEADERS", "group": "hitting"},
    "G": {"api": "games", "title": "G LEADERS", "group": "hitting"},
    "AB": {"api": "atBats", "title": "AB LEADERS", "group": "hitting"},
    "R": {"api": "runs", "title": "R LEADERS", "group": "hitting"},
    "H": {"api": "hits", "title": "H LEADERS", "group": "hitting"},
    "2B": {"api": "doubles", "title": "2B LEADERS", "group": "hitting"},
    "3B": {"api": "triples", "title": "3B LEADERS", "group": "hitting"},
    "HR": {"api": "homeRuns", "title": "HR LEADERS", "group": "hitting"},
    "RBI": {"api": "runsBattedIn", "title": "RBI LEADERS", "group": "hitting"},
    "BB": {"api": "walks", "title": "BB LEADERS", "group": "hitting"},
    "SO": {"api": "strikeOuts", "title": "SO LEADERS", "group": "hitting"},
    "SB": {"api": "stolenBases", "title": "SB LEADERS", "group": "hitting"},
    "CS": {"api": "caughtStealing", "title": "CS LEADERS", "group": "hitting"},
    "AVG": {"api": "battingAverage", "title": "AVG LEADERS", "group": "hitting"},
    "OBP": {"api": "onBasePercentage", "title": "OBP LEADERS", "group": "hitting"},
    "SLG": {"api": "sluggingPercentage", "title": "SLG LEADERS", "group": "hitting"},
    "OPS": {"api": "onBasePlusSlugging", "title": "OPS LEADERS", "group": "hitting"},
    "HBP": {"api": "hitByPitches", "title": "HBP LEADERS", "group": "hitting"},
    "IW": {"api": "intentionalWalks", "title": "IW LEADERS", "group": "hitting"},
    "W": {"api": "wins", "title": "W LEADERS", "group": "pitching"},
    "L": {"api": "losses", "title": "L LEADERS", "group": "pitching"},
    "ERA": {"api": "earnedRunAverage", "title": "ERA LEADERS", "group": "pitching"},
    "GP": {"api": "gamesPlayed", "title": "G LEADERS", "group": "pitching"},
    "IP": {"api": "inningsPitched", "title": "IP LEADERS", "group": "pitching"},
    "HP": {"api": "hits", "title": "H LEADERS", "group": "pitching"},
    "RP": {"api": "runs", "title": "R LEADERS", "group": "pitching"},
    "HRP": {"api": "homeRuns", "title": "HR LEADERS", "group": "pitching"},
    "BBP": {"api": "walks", "title": "BB LEADERS", "group": "pitching"},
    "SOP": {"api": "strikeOuts", "title": "SO LEADERS", "group": "pitching"},
    "WHIP": {"api": "walksAndHitsPerInningPitched", "title": "WHP LEADERS", "group": "pitching"},
}

def get_team_color(team):
    return TEAM_COLORS.get(team, DEFAULT_COLOR)

def get_text_color(team):
    return TEAM_TEXT_COLORS.get(team, DEFAULT_TEXT)

def format_name(full_name, stat_key):
    name = full_name.split(" ")[-1]
    if stat_key == "OPS":
        return name[:8]
    return name[:9]

def normalize(s):
    return (s or "").lower().replace(" ", "").replace("-", "")

def fetch_group_players(season, group):
    # One API call per group
    categories = ",".join([STAT_CONFIG[s]["api"] for s in STAT_CONFIG if STAT_CONFIG[s]["group"] == group])
    url = "https://statsapi.mlb.com/api/v1/stats/leaders?leaderCategories=%s&season=%s&statGroup=%s&gameType=R" % (categories, season, group)
    resp = http.get(url)
    data = resp.json()

    results = {}
    reverse_map = {normalize(cfg["api"]): k for k, cfg in STAT_CONFIG.items() if cfg["group"] == group}

    for block in data.get("leagueLeaders", []):
        category = normalize(block.get("leaderCategory") or block.get("statType") or block.get("leaderCategoryId"))
        stat_key = reverse_map.get(category)
        if not stat_key:
            for k, cfg in STAT_CONFIG.items():
                if cfg["group"] != group:
                    continue
                api_norm = normalize(cfg["api"])
                if api_norm in category or category in api_norm:
                    stat_key = k
                    break
        if not stat_key:
            continue

        players = []
        for p in block.get("leaders", [])[:3]:
            player = p.get("person", {})
            team = p.get("team", {})
            team_name = team.get("name") or ""
            team_abbr = TEAM_NAME_MAP.get(team_name, "")
            players.append({
                "name": format_name(player.get("fullName", "?"), stat_key),
                "team": team_abbr,
                "stat": p.get("value", "?"),
            })
        results[stat_key] = players
    return results

def row(player):
    team = player["team"]
    return render.Box(
        width = 64,
        height = 8,
        color = get_team_color(team),
        child = render.Row(
            expanded = True,
            main_align = "space_between",
            cross_align = "center",
            children = [
                render.Row(
                    children = [
                        render.Box(width = 2),
                        render.Text(content = player["name"], color = get_text_color(team), font = "tb-8"),
                    ],
                ),
                render.Row(
                    children = [
                        render.Text(content = str(player["stat"]), color = get_text_color(team), font = "tb-8"),
                        render.Box(width = 1),
                    ],
                ),
            ],
        ),
    )

def stat_frame(title, players):
    return render.Column(
        children = [
            render.Row(
                children = [
                    render.Box(
                        width = 16,
                        height = 8,
                        child = render.Row(
                            children = [
                                render.Box(width = 1),
                                render.Text(content = "MLB", color = "#FFB000"),
                            ],
                        ),
                    ),
                    render.Box(
                        width = 48,
                        height = 8,
                        child = render.Row(
                            expanded = True,
                            main_align = "end",
                            children = [
                                render.Text(content = title, color = "#FFFFFF", font = "CG-pixel-3x5-mono"),
                            ],
                        ),
                    ),
                ],
            ),
            render.Column(children = [row(p) for p in players]),
        ],
    )

def main(config):
    rotationSpeed = config.get("rotationSpeed", "5")

    stat_keys = [
        config.get("stat1", "HR"),
        config.get("stat2", "None"),
        config.get("stat3", "None"),
        config.get("stat4", "None"),
        config.get("stat5", "None"),
        config.get("stat6", "None"),
        config.get("stat7", "None"),
        config.get("stat8", "None"),
        config.get("stat9", "None"),
        config.get("stat10", "None"),
    ]

    stat_keys = [s for s in stat_keys if s != "None"]
    if not stat_keys:
        stat_keys = ["None"]

    today = time.now().in_location("America/New_York")
    season = str(today.year)

    hitting = fetch_group_players(season, "hitting")
    pitching = fetch_group_players(season, "pitching")

    all_players = {}
    all_players.update(hitting)
    all_players.update(pitching)

    frames = []
    for stat_key in stat_keys:
        players = all_players.get(stat_key, [])
        if not players:
            players = [
                {"name": "Yuk", "team": "NYY", "stat": 88},
                {"name": "Dum", "team": "LAD", "stat": 88},
                {"name": "Boo", "team": "PHI", "stat": 88},
            ]
        frames.append(stat_frame(STAT_CONFIG[stat_key]["title"], players))

    return render.Root(
        delay = int(rotationSpeed) * 1000,
        show_full_animation = True,
        child = render.Animation(children = frames),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(id = "rotationSpeed", name = "Rotation Speed", desc = "Amount of seconds each score is displayed.", icon = "clock", default = rotationOptions[4].value, options = rotationOptions),
            schema.Dropdown(id = "stat1", name = "Stat 1", desc = "The first stat to show.", icon = "baseball", default = statOptions[7].value, options = statOptions),
            schema.Dropdown(id = "stat2", name = "Stat 2", desc = "The second stat to show.", icon = "baseball", default = statOptions[13].value, options = statOptions),
            schema.Dropdown(id = "stat3", name = "Stat 3", desc = "The third stat to show.", icon = "baseball", default = statOptions[8].value, options = statOptions),
            schema.Dropdown(id = "stat4", name = "Stat 4", desc = "The fourth stat to show.", icon = "baseball", default = statOptions[16].value, options = statOptions),
            schema.Dropdown(id = "stat5", name = "Stat 5", desc = "The fifth stat to show.", icon = "baseball", default = statOptions[11].value, options = statOptions),
            schema.Dropdown(id = "stat6", name = "Stat 6", desc = "The sixth stat to show.", icon = "baseball", default = statOptions[21].value, options = statOptions),
            schema.Dropdown(id = "stat7", name = "Stat 7", desc = "The seventh stat to show.", icon = "baseball", default = statOptions[0].value, options = statOptions),
            schema.Dropdown(id = "stat8", name = "Stat 8", desc = "The eighth stat to show.", icon = "baseball", default = statOptions[0].value, options = statOptions),
            schema.Dropdown(id = "stat9", name = "Stat 9", desc = "The ninth stat to show.", icon = "baseball", default = statOptions[0].value, options = statOptions),
            schema.Dropdown(id = "stat10", name = "Stat 10", desc = "The tenth stat to show.", icon = "baseball", default = statOptions[0].value, options = statOptions),
        ],
    )

# Schema and options (keep unchanged)
statOptions = [
    schema.Option(display = "None", value = "None"),  #0
    schema.Option(display = "G", value = "G"),  #1
    schema.Option(display = "AB", value = "AB"),  #2
    schema.Option(display = "R", value = "R"),  #3
    schema.Option(display = "H", value = "H"),  #4
    schema.Option(display = "2B", value = "2B"),  #5
    schema.Option(display = "3B", value = "3B"),  #6
    schema.Option(display = "HR", value = "HR"),  #7
    schema.Option(display = "RBI", value = "RBI"),  #8
    schema.Option(display = "BB", value = "BB"),  #9
    schema.Option(display = "SO", value = "SO"),  #10
    schema.Option(display = "SB", value = "SB"),  #11
    schema.Option(display = "CS", value = "CS"),  #12
    schema.Option(display = "AVG", value = "AVG"),  #13
    schema.Option(display = "OBP", value = "OBP"),  #14
    schema.Option(display = "SLG", value = "SLG"),  #15
    schema.Option(display = "OPS", value = "OPS"),  #16
    schema.Option(display = "HBP", value = "HBP"),  #17
    schema.Option(display = "IW", value = "IW"),  #18
    schema.Option(display = "W(P)", value = "W"),  #19
    schema.Option(display = "L(P)", value = "L"),  #20
    schema.Option(display = "ERA(P)", value = "ERA"),  #21
    schema.Option(display = "G(P)", value = "GP"),  #22
    schema.Option(display = "IP(P)", value = "IP"),  #23
    schema.Option(display = "H(P)", value = "HP"),  #24
    schema.Option(display = "R(P)", value = "RP"),  #25
    schema.Option(display = "HR(P)", value = "HRP"),  #26
    schema.Option(display = "BB(P)", value = "BBP"),  #27
    schema.Option(display = "SO(P)", value = "SOP"),  #28
    schema.Option(display = "WHIP(P)", value = "WHIP"),  #29
]
rotationOptions = [
    schema.Option(display = "1 second", value = "1"),
    schema.Option(display = "2 seconds", value = "2"),
    schema.Option(display = "3 seconds", value = "3"),
    schema.Option(display = "4 seconds", value = "4"),
    schema.Option(display = "5 seconds", value = "5"),
    schema.Option(display = "6 seconds", value = "6"),
    schema.Option(display = "7 seconds", value = "7"),
    schema.Option(display = "8 seconds", value = "8"),
    schema.Option(display = "9 seconds", value = "9"),
    schema.Option(display = "10 seconds", value = "10"),
    schema.Option(display = "11 seconds", value = "11"),
    schema.Option(display = "12 seconds", value = "12"),
    schema.Option(display = "13 seconds", value = "13"),
    schema.Option(display = "14 seconds", value = "14"),
    schema.Option(display = "15 seconds", value = "15"),
]
