/** @type {import('tailwindcss').Config} */
module.exports = {
    darkMode: 'class',
    content: [
        "./src/**/*.{html,ts}",
    ],
    theme: {
        extend: {
            fontSize: {
                'xs': 'clamp(0.75rem, 0.71rem + 0.20vw, 0.875rem)',
                'sm': 'clamp(0.875rem, 0.84rem + 0.18vw, 1rem)',
                'base': 'clamp(1rem, 0.95rem + 0.25vw, 1.125rem)',
                'lg': 'clamp(1.125rem, 1.05rem + 0.38vw, 1.5rem)',
                'xl': 'clamp(1.25rem, 1.12rem + 0.65vw, 2rem)',
                'display': 'clamp(2rem, 1.50rem + 2.50vw, 4rem)',
            },
            colors: {
                // ── Spectroscopic Kaizen Medical Triage Palette ──────────────
                // Each tier maps to a physical wavelength in the visible spectrum.
                // Light theme: Emission spectrum (bright, saturated on white).
                // Dark theme:  Absorption spectrum (desaturated glow on zinc).
                spectral: {
                    // P1 Immediate — 640nm Spectral Red
                    critical: {
                        DEFAULT: 'var(--spectral-critical)',
                        bg:      'var(--spectral-critical-bg)',
                        border:  'var(--spectral-critical-border)',
                        muted:   'var(--spectral-critical-muted)',
                    },
                    // P2 Urgent — 585nm Sodium Amber
                    urgent: {
                        DEFAULT: 'var(--spectral-urgent)',
                        bg:      'var(--spectral-urgent-bg)',
                        border:  'var(--spectral-urgent-border)',
                        muted:   'var(--spectral-urgent-muted)',
                    },
                    // P3 Delayed / Stable — 532nm Emerald Green
                    stable: {
                        DEFAULT: 'var(--spectral-stable)',
                        bg:      'var(--spectral-stable-bg)',
                        border:  'var(--spectral-stable-border)',
                        muted:   'var(--spectral-stable-muted)',
                    },
                    // Informational / AI — 470nm Cerulean Blue
                    info: {
                        DEFAULT: 'var(--spectral-info)',
                        bg:      'var(--spectral-info-bg)',
                        border:  'var(--spectral-info-border)',
                        muted:   'var(--spectral-info-muted)',
                    },
                    // Research / Provenance — 420nm Violet-Indigo
                    research: {
                        DEFAULT: 'var(--spectral-research)',
                        bg:      'var(--spectral-research-bg)',
                        border:  'var(--spectral-research-border)',
                        muted:   'var(--spectral-research-muted)',
                    },
                },
            },
        },
    },
    plugins: [
        require('@tailwindcss/typography'),
    ],
}
