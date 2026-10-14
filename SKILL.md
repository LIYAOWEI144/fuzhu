---
name: gromacs-analysis-assistant
description: Audit a prepared GROMACS system and a user-supplied command list before equilibration, production MD, or trajectory analysis. Produces a Chinese command-review text file and preflight report; use with receptor-ligand merge and ligand parameterization packages.
---

# GROMACS Analysis Assistant

## Purpose

Prepare an existing, parameterized GROMACS system for a reproducible manual
workflow. This skill does not replace ligand parameterization or topology
merging. Use it after `gromacs-receptor-ligand-merge` and, when applicable,
`gromacs-ligand-qm-refinement`.

## Required Inputs

Obtain the coordinate (`.gro`), topology (`.top` and included `.itp` files),
MDP files, GROMACS version, and any user command file. Establish which phase
the user wants to prepare: solvation/ionization, EM, NVT, NPT, production, or
trajectory analysis.

If generating any new project-facing artifact beyond an already selected
delivery folder, ask the user for all three items before writing it:

1. output directory;
2. file type/name; and
3. whether it is a runnable simulation input, a report, or an analysis output.

The expected output of a command audit is a `.txt` report, but do not assume
its project destination when the user has not supplied one.

## Mandatory Preflight

1. Resolve the topology include graph. Every local include must exist, be
   read in valid GROMACS directive order, and use one compatible force-field
   family. Do not substitute a stock GROMACS force field for a CGenFF ligand.
2. Compare the coordinate residue names/counts with `[ molecules ]`. If
   solvent is present, `SOL` needs a compatible water molecule definition. If
   ions are present, include only molecule types whose atom types exist in the
   selected force field; a universal ion file may reference unrelated missing
   types.
3. Inspect conditional position restraints. A macro in an `.itp` must either
   be inactive or have numerical force constants supplied in the relevant MDP.
   Keep protein and ligand restraint macros distinct when their protocols
   differ.
4. Run `gmx grompp` at each intended stage with `-maxwarn 0` first. Diagnose
   warnings individually; never use `-maxwarn` merely to pass a broken setup.
5. Treat a short unconstrained-bond-period warning as a stability decision:
   reduce `dt` or use an explicitly justified compatible constraint scheme.
   Re-run `grompp` after the change.

## Command Review

When the user supplies a command file, create a UTF-8 `.txt` review after the
output location is known. For every altered or risky command, show exactly:

```text
原命令：...
建议命令：...
原因：...
```

Retain commands that need no change and state that they passed review. The
review must call out: force-field/water-model compatibility, ion topology
definitions, selected `genion` solvent group, `-maxwarn`, positional-restraint
macros, continuation coordinates/checkpoints, production barostat, and output
frequency. Use `scripts/generate_command_review.ps1` as a first-pass report,
then add any system-specific `grompp` findings.

Read [observed incidents](references/observed-incidents.md) when the system
resembles a CHARMM/CGenFF receptor-ligand workflow or when a prior `grompp`
failure must be prevented rather than merely bypassed.

## Storage-Aware Production Settings

For routine structural analyses (RMSD, RMSF, Rg, SASA, hydrogen bonds), retain
a compressed `.xtc` at a user-appropriate stride and energies/logs. Avoid
simultaneously writing an uncompressed coordinate trajectory and a velocity
trajectory unless the intended analysis needs them. State the chosen stride
and estimate disk use before a long run. Do not delete existing trajectories.

## Validation and Handoff

Do not claim production readiness until the final production `.tpr` is created
without suppressed warnings. Before trajectory analyses, create a PBC-corrected
analysis trajectory while retaining the original production trajectory. Use
index groups verified against the actual topology rather than fixed group
numbers from a tutorial.

