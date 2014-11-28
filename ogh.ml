let gh_user = Sys.getenv "GITHUB_USER"
let gh_pass = Sys.getenv "GITHUB_PASSWORD"
let gh_api_base_url = "https://api.github.com"

let ask_github fn = Github.(Monad.run (fn ()))

let get_token cookie_name =
  let open Lwt in
  Github_cookie_jar.init () >>= fun ghcj ->
  Github_cookie_jar.get ghcj ~name:"ogh" >>= fun auth ->
  return (Github.Token.of_auth (BatOption.get auth))

let make_org_teams_uri ~org =
  Uri.of_string (Printf.sprintf "%s/orgs/%s/teams" gh_api_base_url org)

let make_team_repos_uri ~team =
  Uri.of_string (Printf.sprintf "%s/teams/%d/repos" gh_api_base_url team)

let print_repo_info ~m =
  let open Printf in
  let open Github_t in
  eprintf "  repo %s: %s (%d watchers, %d open issues)\n%!"
          m.repo_name m.repo_description m.repo_watchers m.repo_open_issues

let print_repo_branches ~repo_branches =
  let open Printf in
  let open Github_t in
  let open Lwt in
  let print_branch b = eprintf "branch %s: %s\n%!"
                             b.repo_branch_name
                             b.repo_branch_commit.repo_commit_url in
  List.iter print_branch repo_branches;
  return ()

let get_owners_id ~org_teams_json =
  let open Yojson.Basic.Util in
  let json = Yojson.Basic.from_string org_teams_json in
  let is_owners team_el = (team_el |> member "name" |> to_string) = "Owners" in
  let owners_team = List.filter is_owners (json |> to_list) in
  List.hd owners_team |> member "id" |> to_int

let get_repos ~team_repos_json =
  let open Yojson.Basic.Util in
  let json = Yojson.Basic.from_string team_repos_json in
  json |> to_list

let get_repo_name ~repo_info_json =
  let open Yojson.Basic.Util in
  repo_info_json |> member "name" |> to_string

let get_org_owners_id ~token ~org =
  let open Lwt in
  let org_teams_uri = make_org_teams_uri org in
  let handle_response s = return (get_owners_id s) in
  Github.Monad.run (Github.API.get ~token:token ~uri:org_teams_uri handle_response)

let get_team_repos ~token ~team =
  let open Lwt in
  let team_repos_uri = make_team_repos_uri team in
  let handle_response s = return (get_repos s) in
  Github.Monad.run (Github.API.get ~token:token ~uri:team_repos_uri handle_response)

let print_repo_branches ~token ~org ~repo =
  let open Lwt in
  Printf.eprintf "%s/%s:\n%!" org repo;
  ask_github (Github.Repo.branches ~token:token ~user:org ~repo:repo) >>= fun repo_branches ->
  print_repo_branches repo_branches

(* This code assumes you have already gotten the token
   and saved it locally in your cookie jar *)
let print_org_repos ~cookie_name ~org =
  let open Lwt in
  get_token cookie_name >>= fun token ->
  get_org_owners_id token org >>= fun owners_id ->
  get_team_repos token owners_id >>= fun team_repos ->
  let print_from_json repo = print_repo_branches token org (get_repo_name repo) in
  Lwt_list.iter_s print_from_json team_repos >>= fun () ->
  return ()

let _ = Lwt_main.run (print_org_repos "ogh" "hammerlab")

