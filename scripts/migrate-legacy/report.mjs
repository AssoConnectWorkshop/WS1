import { writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dir = dirname(fileURLToPath(import.meta.url));

async function safeQuery(pgPool, text, params = []) {
  try {
    const { rows } = await pgPool.query(text, params);
    return rows;
  } catch (err) {
    return [{ erreur: err.message }];
  }
}

function table(rows) {
  if (rows.length === 0) return '_(aucune ligne)_\n';
  const cols = Object.keys(rows[0]);
  const header = `| ${cols.join(' | ')} |`;
  const sep = `| ${cols.map(() => '---').join(' | ')} |`;
  const body = rows.map((r) => `| ${cols.map((c) => r[c] ?? '').join(' | ')} |`).join('\n');
  return `${header}\n${sep}\n${body}\n`;
}

export async function writeReport(pgPool, report) {
  const lines = [];
  lines.push(`# Rapport de transfert — ${report.startedAt}`);
  lines.push('');
  lines.push(report.dryRun ? '**Mode `--dry-run` : aucune écriture n\'a été faite.**' : 'Écritures effectuées sur Supabase.');
  lines.push('');

  lines.push('## Par table');
  lines.push('');
  lines.push('| Table | Lignes source | Lignes transformées | Écrites | Total dans la table |');
  lines.push('| --- | --- | --- | --- | --- |');
  for (const [name, r] of Object.entries(report.tables)) {
    const ecart = r.targetCountAfter != null ? r.sourceCount - r.targetRows : '—';
    lines.push(
      `| ${name} | ${r.sourceCount} | ${r.targetRows} | ${r.written} | ${r.targetCountAfter ?? '—'} (écart transform=${ecart}) |`
    );
  }
  lines.push('');

  const signalements = Object.entries(report).filter(([k]) => k !== 'tables' && k !== 'startedAt' && k !== 'dryRun');
  if (signalements.length > 0) {
    lines.push('## Signalements (codes de référentiel découverts, orphelins...)');
    lines.push('');
    for (const [key, values] of signalements) {
      lines.push(`- **${key}** (${values.length}) : ${values.slice(0, 50).join(', ')}${values.length > 50 ? '…' : ''}`);
    }
    lines.push('');
  }

  if (!report.dryRun) {
    lines.push('## Interventions par statut');
    lines.push('');
    lines.push(
      table(
        await safeQuery(
          pgPool,
          `select statut_code, count(*) as n from public.interventions group by statut_code order by statut_code`
        )
      )
    );

    lines.push('## Interventions par type');
    lines.push('');
    lines.push(
      table(
        await safeQuery(
          pgPool,
          `select type_code, count(*) as n from public.interventions group by type_code order by type_code`
        )
      )
    );

    lines.push('## Montants par année de réalisation');
    lines.push('');
    lines.push(
      table(
        await safeQuery(
          pgPool,
          `select extract(year from date_realisee) as annee,
                  sum(montant_fmc) as somme_montant_fmc,
                  sum(montant_sous_traitant) as somme_montant_sous_traitant
           from public.interventions
           where date_realisee is not null
           group by 1 order by 1`
        )
      )
    );

    lines.push('## Devis : nombre et montant HT par famille et statut');
    lines.push('');
    lines.push(
      table(
        await safeQuery(
          pgPool,
          `select famille, statut_code, count(*) as n, sum(montant_ht) as somme_montant_ht
           from public.devis
           group by famille, statut_code
           order by famille, statut_code`
        )
      )
    );

    lines.push('## Sites : 10 plus gros clients');
    lines.push('');
    lines.push(
      table(
        await safeQuery(
          pgPool,
          `select c.nom as client, count(*) as nb_sites
           from public.sites s
           join public.clients c on c.id = s.client_id
           group by c.nom
           order by nb_sites desc
           limit 10`
        )
      )
    );

    lines.push('## Échantillon de 20 sites');
    lines.push('');
    lines.push(
      table(
        await safeQuery(
          pgPool,
          `select s.legacy_id, s.nom, s.ville, c.nom as client,
                  (select count(*) from public.interventions i where i.site_id = s.id) as nb_interventions
           from public.sites s
           join public.clients c on c.id = s.client_id
           order by random()
           limit 20`
        )
      )
    );
  }

  const content = lines.join('\n');
  writeFileSync(join(__dir, 'last-run-report.md'), content, 'utf8');
}
