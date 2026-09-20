# RAM disk sleep hook

systemd system-sleep hook (drop into `home/dot.config/systemd/system-sleep/`
to reactivate) that called `ram-to-disk`/`ram-from-disk` before
suspend and after resume, to persist a RAM disk across sleep. Neither
command was ever implemented, and no current project uses a RAM disk.
Archived rather than deleted in case that setup comes back.
