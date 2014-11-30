let gh_user = Sys.getenv "GITHUB_USER"
let gh_pass = Sys.getenv "GITHUB_PASSWORD"
let gh_api_base_url = "https://api.github.com"

let ask_github ~fn = Github.(Monad.run (fn ()))

let get_token ~cookie_name =
  let open Lwt in
  Github_cookie_jar.init () >>= fun ghcj ->
  Github_cookie_jar.get ghcj ~name:"ogh" >>= fun auth ->
  return (Github.Token.of_auth (BatOption.get auth))

let get_owners_id ~teams =
  let open Github_t in
  let filter_owners team = team.team_name = "Owners" in
  let owners_team = List.hd (List.filter filter_owners teams) in
  owners_team.team_id

(* This code assumes you have already gotten the token
   and saved it locally in your cookie jar *)
let print_org_repos ~cookie_name ~org =
  let open Lwt in
  let open Github_t in
  let open Printf in
  get_token cookie_name >>= fun token ->
  ask_github (Github.Organization.teams ~token:token ~org:org) >>= fun teams ->
  let owners_id = get_owners_id teams in
  ask_github (Github.Team.repos ~token:token ~id:owners_id) >>= fun repos ->
  let get_branches repo =
    let repo_name = repo.repo_name in
    Lwt_io.printlf "Repo: %s" repo_name >>= fun () ->
    ask_github (Github.Repo.branches ~token:token ~user:org ~repo:repo_name) >>= fun branches ->
    Lwt_io.printlf "\tBranches: %s" (Github_j.string_of_repo_branches branches) in
  Lwt_list.iter_s get_branches repos

let _ = Lwt_main.run (print_org_repos "ogh" "hammerlab")

