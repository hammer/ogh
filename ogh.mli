val gh_user : string
val gh_pass : string
val gh_api_base_url : string

val ask_github : (unit -> 'a Github.Monad.t) -> 'a Lwt.t
val get_token : 'a -> Github.Token.t Lwt.t

val make_org_teams_uri : org:string -> Uri.t
val make_team_repos_uri : team:int -> Uri.t
val make_repo_branches_uri : org:string -> repo:string -> Uri.t

val print_repo_info : m:Github_t.repo -> unit
val get_owners_id : org_teams_json:string -> int
val get_repos : team_repos_json:string -> Yojson.Basic.json list
val get_repo_name : repo_info_json:Yojson.Basic.json -> string
val get_org_owners_id : token:Github.Token.t -> org:string -> int Lwt.t
val get_team_repos : token:Github.Token.t -> team:int -> Yojson.Basic.json list Lwt.t
val print_repo_branches : token:Github.Token.t -> org:string -> repo:string -> unit Lwt.t
val print_org_repos : cookie_name:'a -> org:string -> unit Lwt.t
