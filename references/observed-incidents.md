# Observed Incident Patterns

The following patterns were recorded from the 2026-10 receptor-ligand
CHARMM/CGenFF workflow. They are case-derived checks, not assumptions about
every GROMACS system.

| Pattern | Immediate symptom | Preventive check |
|---|---|---|
| Missing stage MDP | `File ...mdp does not exist` | Resolve each command-file input before running `grompp`. |
| Incomplete include closure | missing `forcefield.itp` or supplement `.itp` | Traverse every quoted include and package the compatible closure. |
| Invalid include order | `Invalid order for directive atomtypes` | Read force-field/type supplements before water or any molecule type. |
| Missing water topology | `No such moleculetype SOL` | Require compatible water definition after solvation. |
| Over-broad ion topology | undefined unrelated atom type such as `AG1P` | Include only ion types that occur in the actual coordinate/molecule table. |
| Undefined position-restraint constants | hundreds of `No default Position Rest. types` errors | Check active macro branches and require numeric MDP definitions. |
| Fast unconstrained ligand bond | `grompp` bond-period warning at 2 fs | Make and document a timestep/constraint decision before production. |
| Production Berendsen barostat | GROMACS ensemble warning | Use Berendsen only for equilibration; select a production-appropriate barostat. |
| Redundant trajectory streams | multi-GB to tens-of-GB estimate | Keep compressed XTC for structural analyses; justify TRR and velocities separately. |

Do not treat `-maxwarn` as remediation for any entry in this table.
