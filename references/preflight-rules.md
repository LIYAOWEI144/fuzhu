# GROMACS Preflight Rules

## Water and Ions

- `gmx solvate -cs spc216.gro` supplies three-site water coordinates; the
  topology still must include the water molecule definition and atom types
  compatible with the selected force field. Check `SOL` before ionization.
- After `gmx genion`, the generated coordinate residues and `[ molecules ]`
  table must agree. Define only the ion molecule types actually present. A
  broad `ions.itp` is unsafe when it introduces atom types absent from a
  reduced CHARMM/CGenFF force-field file.

## Warnings

- Start every new stage with `gmx grompp` without `-maxwarn`.
- A missing include, unknown molecule type, invalid directive order, or
  undefined restraint constant is an error, not a warning to suppress.
- Berendsen pressure coupling is reasonable for an equilibration stage but
  does not generate a strictly correct production NPT ensemble. Use a
  production-appropriate barostat supported by the local GROMACS version,
  such as C-rescale when validated for the protocol.

## Restraints and Timesteps

- Keep topology restraint blocks conditional. Use separate macros, such as
  `POSRES_PROTEIN` and `POSRES_LIG`, when protein and ligand do not share the
  same protocol.
- A symbolic restraint force constant, for example `POSRES_FC_BB`, requires a
  numeric preprocessor definition in the MDP when its restraint block is
  active.
- A `grompp` warning about an unconstrained fast bond must be resolved by a
  justified timestep or constraint decision before production.

## Output Economy

- Structural analysis generally needs XTC, energy, log, checkpoint, final
  coordinates, topology, and MDP provenance.
- Full-precision coordinate/velocity trajectories are optional and can be
  large. Disable them only for future runs and only after confirming no planned
  analysis needs velocities or full precision.

