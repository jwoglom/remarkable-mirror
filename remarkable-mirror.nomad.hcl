job "remarkable-mirror" {
    datacenters = ["dc1"]

    type = "batch"

    reschedule {
        attempts       = 5
        interval       = "6h"
        delay          = "30s"
        delay_function = "exponential"
        max_delay      = "30m"
        unlimited      = false
    }

    periodic {
        cron = "0 */3 * * *"
        prohibit_overlap = true
    }

    group "default" {
        count = 1
        volume "remarkable_rmapi_config" {
            type = "host"
            source = "remarkable_rmapi_config"
        }

        task "default" {
            driver = "docker"

            config {
                image = "ghcr.io/jwoglom/remarkable-mirror/remarkable-mirror"
                privileged = true

                entrypoint = ["bash"]
                args = [
                    "-c",
                    <<EOF
                    ln -s /rmapi_config/rmapi /home/appuser/.rmapi
                    python3 -u main.py --config-folder=/config --tmp-folder=$NOMAD_ALLOC_DIR
                    EOF
                ]
            }

            resources {
                cpu = 100
                memory = 700 # occasional spikes over 500mb
            }

            volume_mount {
                volume = "remarkable_rmapi_config"
                destination = "/rmapi_config"
            }

            kill_timeout = "60s"

            env {
                TZ = "America/New_York"
            }
        }
    }
}