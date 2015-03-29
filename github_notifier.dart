import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginStorage("config")
Storage config;

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

Map<String, dynamic> STATUS_CI = {};

String networkOf(String input) {
  return input.split(":")[0];
}

String channelOf(String input) {
  return input.split(":")[1];
}

String getRepoName(Map<String, dynamic> repo) {
  if (repo["full_name"] != null) {
    return repo["full_name"];
  } else {
    return "${repo["owner"]["name"]}/${repo["name"]}";
  }
}

List<String> channelsFor(String id) {
  var chans = config.getSubStorage("channels");

  if (chans.has(id)) {
    return chans.getList(id, defaultValue: []);
  } else if (config.has("default_channels")) {
    return config.getList("default_channels", defaultValue: []);
  } else {
    return [];
  }
}

String getRepoOwner(Map<String, dynamic> repo) {
  if (repo["owner"]["name"] != null) {
    return repo["owner"]["name"];
  } else {
    return repo["owner"]["login"];
  }
}

String getOrganization() {
  return config.has("organization") ? config.getString("organization") : null;
}

@Command("github-notify", prefix: "GitHub Notifier", permission: "manage")
githubNotify(CommandEvent event) {
  var subs = {
    "add-default-channel": (List<String> args) {
      if (args.length != 2) {
        return "Usage: github-notify add-default-channel <network> <channel>";
      }

      var id = "${args[0]}:${args[1]}";

      if (config.isInList("default_channels", id)) {
        return "Channel is already a default channel.";
      }

      config.addToList("default_channels", id);

      return "Default Channel Added";
    },
    "remove-default-channel": (List<String> args) {
      if (args.length != 2) {
        return "Usage: github-notify remove-default-channel <network> <channel>";
      }

      var id = "${args[0]}:${args[1]}";

      if (!config.isInList("default_channels", id)) {
        return "Channel is not a default channel.";
      }

      config.removeFromList("default_channels", id);

      return "Default Channel Removed";
    },
    "list-default-channels": (List<String> args) {
      if (args.isNotEmpty) {
        return "Usage: github-notify list-default-channels";
      }

      event.replyNotice("Default Channels:");

      DisplayHelpers.paginate(config.getList("default_channels", defaultValue: []), 5, (page, items) {
        event.replyNotice("${items.map((it) => "${networkOf(it)} -> ${channelOf(it)}").join(", ")}");
      });
    }
  };

  if (event.hasNoArguments) {
    return "Usage: github-notify <command>";
  }

  var cmd = event.args[0];

  if (!subs.containsKey(cmd)) {
    return "Usage: github-notify <command>";
  }

  return subs[cmd](event.dropArguments(1));
}

@HttpEndpoint("/hook")
handleHook(HttpRequest request, HttpResponse response) async {
  var json = (await HttpBodyHandler.processRequest(request)).body;
  var handled = true;

  var repoName;

  if (json["repository"] != null) {
    var name = getRepoName(json["repository"]);

    var names = config.getSubStorage("names");

    if (names.has(name)) {
      repoName = names.getString("name");
    } else {
      if (getOrganization() != null) {
        repoName = name;
      } else {
        repoName = json["repository"]["name"];
      }
    }
  }

  void message(String msg, [bool prefix = true]) {
    var m = "";

    if (prefix) {
      m += "[${Color.BLUE}${repoName}${Color.RESET}] ";
    }

    m += msg;

    for (var chan in channelsFor(repoName)) {
      bot.sendMessage(networkOf(chan), channelOf(chan), m);
    }
  }

  switch (request.headers.value('X-GitHub-Event')) {
    case "ping":
      message("[${Color.BLUE}GitHub${Color.RESET}] ${json["zen"]}", false);
      break;
    case "push":
      var refRegex = new RegExp(r"refs/(heads|tags)/(.*)$");
      var branchName = "";
      var tagName = "";
      var isBranch = false;
      var isTag = false;

      if (refRegex.hasMatch(json["ref"])) {
        var match = refRegex.firstMatch(json["ref"]);
        var _type = match.group(1);
        var type = ({"heads": "branch", "tags": "tag"}[_type]);
        if (type == "branch") {
          isBranch = true;
          branchName = match.group(2);
        } else if (type == "tag") {
          isTag = true;
          tagName = match.group(2);
        }
      }

      if (json["commits"] != null && json["commits"].length != 0) {
        if (json['repository']['fork']) break;
        var pusher = json['pusher']['name'];
        var commit_size = json['commits'].length;

        shortenUrl(json["compare"]).then((compareUrl) {
          var committer = "${Color.OLIVE}$pusher${Color.RESET}";
          var commit = "commit${commit_size > 1 ? "s" : ""}";
          var branch =
              "${Color.DARK_GREEN}${json['ref'].split("/")[2]}${Color.RESET}";

          var url = "${Color.PURPLE}${compareUrl}${Color.RESET}";
          message(
              "$committer pushed ${Color.DARK_GREEN}$commit_size${Color.RESET} $commit to $branch - $url");

          int tracker = 0;
          for (var commit in json['commits']) {
            tracker++;
            if (tracker > 5) break;
            committer =
                "${Color.OLIVE}${commit['committer']['name']}${Color.RESET}";
            var sha =
                "${Color.DARK_GREEN}${commit['id'].substring(0, 7)}${Color.RESET}";
            message("$committer $sha - ${commit['message']}");
          }
        });
      } else if (isTag) {
        if (json['repository']['fork']) break;
        String out = "";
        if (json['pusher'] != null) {
          out +=
              "${Color.OLIVE}${json["pusher"]["name"]}${Color.RESET} tagged ";
        } else {
          out += "Tagged ";
        }
        out +=
            "${Color.DARK_GREEN}${json['head_commit']['id'].substring(0, 7)}${Color.RESET} as ";
        out += "${Color.DARK_GREEN}${tagName}${Color.RESET}";
        message(out);
      } else if (isBranch) {
        if (json['repository']['fork']) break;
        String out = "";
        if (json["deleted"]) {
          if (json["pusher"] != null) {
            out +=
                "${Color.OLIVE}${json["pusher"]["name"]}${Color.RESET} deleted branch ";
          } else {
            out += "Deleted branch";
          }
        } else {
          if (json["pusher"] != null) {
            out +=
                "${Color.OLIVE}${json["pusher"]["name"]}${Color.RESET} created branch ";
          } else {
            out += "Created branch";
          }
        }

        out += "${Color.DARK_GREEN}${branchName}${Color.RESET}";

        var longUrl = "";

        if (json["head_commit"] == null) {
          longUrl = json["compare"];
        } else {
          longUrl = json["head_commit"]["url"];
        }

        shortenUrl(longUrl).then((url) {
          out += " - ${Color.PURPLE}${url}${Color.RESET}";
          message(out);
        });
      }
      break;

    case "issues":
      var action = json["action"];
      var by = json["sender"]["login"];
      var issueId = json["issue"]["number"];
      var issueName = json["issue"]["title"];
      var issueUrl = json["issue"]["html_url"];
      shortenUrl(issueUrl).then((url) {
        message(
            "${Color.OLIVE}${by}${Color.RESET} ${action} the issue '${issueName}' (${issueId}) - ${url}");
      });
      break;

    case "release":
      var action = json["action"];
      var author = json["sender"]["login"];
      var name = json["release"]["name"];
      shortenUrl(json["release"]["html_url"]).then((url) {
        message(
            "${Color.OLIVE}${author}${Color.RESET} ${action} the release '${name}' - ${url}");
      });
      break;

    case "fork":
      var forkee = json["forkee"];
      shortenUrl(forkee["html_url"]).then((url) {
        message(
            "${Color.OLIVE}${getRepoOwner(forkee)}${Color.RESET} created a fork at ${forkee["full_name"]} - ${url}");
      });
      break;
    case "commit_comment":
      var who = json["sender"]["login"];
      var commit_id = json["comment"]["commit_id"].substring(0, 10);
      message(
          "${Color.OLIVE}${who}${Color.RESET} commented on commit ${commit_id}");
      break;
    case "issue_comment":
      var issue = json["issue"];
      var sender = json["sender"];
      var action = json["action"];

      if (action == "created") {
        shortenUrl(json["comment"]["html_url"]).then((url) {
          message(
              "${Color.OLIVE}${sender["login"]}${Color.RESET} commented on issue #${issue["number"]} - $url");
        });
      }

      break;
    case "watch":
      var who = json["sender"]["login"];
      message("${Color.OLIVE}${who}${Color.RESET} starred the repository");
      break;
    case "page_build":
      var build = json["build"];
      var who = build["pusher"]["login"];
      var msg = "";
      if (build["error"]["message"] != null) {
        msg +=
            "${Color.OLIVE}${who}${Color.RESET} Page Build Failed (Message: ${build["error"]["message"]})";
        message(msg);
      }
      break;
    case "gollum":
      var who = json["sender"]["login"];
      var pages = json["pages"];
      for (var page in pages) {
        var name = page["title"];
        var type = page["action"];
        var summary = page["summary"];
        var msg =
            "${Color.OLIVE}${who}${Color.RESET} ${type} '${name}' on the wiki";
        if (summary != null) {
          msg += " (${msg})";
        }
        message(msg);
      }
      break;

    case "pull_request":
      var who = json["sender"]["login"];
      var pr = json["pull_request"];
      var number = json["number"];

      var action = json["action"];

      if (["opened", "reopened", "closed"].contains(action)) {
        shortenUrl(pr["html_url"]).then((url) {
          message(
              "${Color.OLIVE}${who}${Color.RESET} ${action} a Pull Request (#${number}) - ${url}");
        });
      }

      break;

    case "public":
      var repo = json["repository"];
      shortenUrl(repo["html_url"]).then((url) {
        message(
            "${json["sender"]["login"]} made the repository public: ${url}");
      });
      break;

    case "status":
      var msg = "";
      var status = json["state"];
      var targetUrl = json["target_url"];
      var sha = json["sha"];

      if (status == "pending" && STATUS_CI[sha] == null) {
        STATUS_CI[sha] = "pending";
      } else if (STATUS_CI[sha] != null &&
          STATUS_CI[sha] == "pending" &&
          status == "pending") {
        return;
      } else if (STATUS_CI[sha] == "pending" &&
          (status == "success" || status == "failure")) {
        STATUS_CI.remove(sha);
      }

      if (status == "pending") {
        status = "${Color.DARK_GRAY}Pending${Color.RESET}.";
      } else if (status == "success") {
        status = "${Color.DARK_GREEN}Success${Color.RESET}.";
      } else {
        status = "${Color.RED}Failure${Color.RESET}.";
      }
      msg += status;
      msg += " ";
      msg += json["description"];
      msg += " - ";
      shortenUrl(targetUrl).then((url) {
        msg += "${Color.MAGENTA}${url}${Color.RESET}";
        message(msg);
      });
      break;

    case "team_add":
      var team = json["team"];
      var msg = "";
      if (json["user"] != null) {
        msg +=
            "${Color.OLIVE}${json["sender"]["login"]}${Color.RESET} has added ";
        msg +=
            "${Color.OLIVE}${json["user"]["login"]}${Color.RESET} to the '${team["name"]}' team.";
        message(msg);
      }
      break;

    default:
      handled = false;
      break;
  }

  response.writeln(encodeJSON({
    "handled": handled
  }, pretty: true));
  response.close();
}
