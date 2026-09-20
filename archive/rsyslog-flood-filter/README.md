# rsyslog flood filter

Example rsyslog drop-in (belongs in `system/etc/rsyslog.d/` to
reactivate, gets sudo-installed by `setup`) that stops
`plasmashell`/`warp-svc` messages above severity 4 from being logged.
Not currently deployed — silently dropping messages above a severity
threshold risks hiding a real problem from those programs, not just
noise. Kept as a template for filtering a specific flooding
program/severity if the same issue recurs.
