import { execSync } from 'child_process';

try {
  // 1. Project ID
  const projectId = execSync('gcloud config get-value project', { encoding: 'utf-8' }).trim();
  console.log(`Current project: ${projectId}`);

  // 2. Artifact Registry
  const repo = `us-west1-docker.pkg.dev/${projectId}/cloud-run-source-deploy/pocket-gull`;
  console.log(`Checking repository: ${repo}`);
  
  const stdout = execSync(`gcloud artifacts docker images list ${repo} --format=json`, { encoding: 'utf-8' });
  const images = JSON.parse(stdout);
  if (images && images.length > 2) {
    images.sort((a, b) => new Date(b.updateTime) - new Date(a.updateTime));
    const toDelete = images.slice(2);
    console.log(`Keeping latest 2. Deleting ${toDelete.length} old images...`);
    for (const img of toDelete) {
      let versionPart = img.version;
      if (versionPart.startsWith('sha256')) {
         versionPart = versionPart.split(':')[1] || versionPart;
      }
      const fullPath = `${repo}@sha256:${versionPart.replace('sha256:', '')}`;
      console.log(`Deleting ${fullPath}...`);
      execSync(`gcloud artifacts docker images delete "${fullPath}" --quiet`, { stdio: 'inherit' });
    }
  } else {
    console.log('No artifacts to clean up.');
  }

  // 3. Cloud Run Revisions
  console.log('Fetching service info for pocket-gull...');
  const svcStdout = execSync('gcloud run services describe pocket-gull --region us-west1 --format=json', { encoding: 'utf-8' });
  const service = JSON.parse(svcStdout);
  const activeTrafficRevisions = new Set((service.status.traffic || []).map(t => t.revisionName));
  if (service.status.latestCreatedRevisionName) activeTrafficRevisions.add(service.status.latestCreatedRevisionName);
  if (service.status.latestReadyRevisionName) activeTrafficRevisions.add(service.status.latestReadyRevisionName);

  const revStdout = execSync('gcloud run revisions list --service pocket-gull --region us-west1 --format=json', { encoding: 'utf-8' });
  const revisions = JSON.parse(revStdout);
  const toDeleteRev = revisions.filter(r => !activeTrafficRevisions.has(r.metadata.name));
  
  if (toDeleteRev.length > 0) {
    console.log(`Found ${toDeleteRev.length} inactive revisions to delete out of ${revisions.length} total.`);
    for (const rev of toDeleteRev) {
      console.log(`Deleting revision: ${rev.metadata.name}...`);
      execSync(`gcloud run revisions delete ${rev.metadata.name} --region us-west1 --quiet`, { stdio: 'inherit' });
    }
  } else {
    console.log('No revisions to clean up.');
  }
  
  console.log('v1 cleanup complete.');
} catch (e) {
  console.error('Error:', e.message);
}
