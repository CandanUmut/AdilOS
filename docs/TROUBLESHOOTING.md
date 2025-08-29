# Troubleshooting

- **Black screen after boot**: collect logs via serial/adb; confirm compositor running; try Phosh session
- **No touch**: verify input device nodes; check dtb overlays
- **No SIM**: ensure ModemManager/ofono running; APN configured
- **Wi‑Fi off**: check firmware path; dmesg for regulatory errors
