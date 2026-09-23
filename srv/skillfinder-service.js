const cds = require('@sap/cds');
const { SELECT, INSERT } = cds.ql;

module.exports = cds.service.impl(async function () {
  const { Users, Profiles, Skills, Experiences, Educations, Certifications, Languages, GeneratedCVs } = this.entities;

  this.on('me', async req => {
    const email = req.user.id;
    const user = await SELECT.one.from(Users).where({ email });
    if (!user) return req.reject(404, `Aucun utilisateur fonctionnel pour ${email}`);
    const profile = await SELECT.one.from(Profiles).columns('ID').where({ user_ID: user.ID });
    return { id: user.ID, role: req.user.is('Admin') ? 'ADMIN' : 'USER', displayName: user.displayName, email, profileId: profile?.ID };
  });

  this.on('dashboardStats', async req => {
    if (!req.user.is('Admin')) return req.reject(403);
    const count = async entity => Number((await SELECT.one.from(entity).columns('count(1) as n')).n);
    return { users: await count(Users), profiles: await count(Profiles), cvs: await count(GeneratedCVs), skills: await count(Skills) };
  });

  this.on('advancedSearch', async req => {
    if (!req.user.is('Admin')) return req.reject(403);
    const { skill, minYears, certification } = req.data;
    let q = SELECT.distinct.from(Profiles).columns(p => { p('*'); p.user(u => { u.displayName; u.email; }); });
    const conditions = [];
    if (minYears != null) conditions.push({ ref: ['totalExperienceYears'] }, '>=', { val: Number(minYears) });
    if (conditions.length) q.where(...conditions);
    let rows = await q;
    if (skill) {
      const ids = new Set((await SELECT.from(Skills).columns('profile_ID').where({ name: { like: `%${skill}%` } })).map(x => x.profile_ID));
      rows = rows.filter(x => ids.has(x.ID));
    }
    if (certification) {
      const ids = new Set((await SELECT.from(Certifications).columns('profile_ID').where({ name: { like: `%${certification}%` } })).map(x => x.profile_ID));
      rows = rows.filter(x => ids.has(x.ID));
    }
    return rows;
  });

  this.on('generateCV', async req => {
    const { profileId } = req.data;
    const profile = await SELECT.one.from(Profiles).where({ ID: profileId });
    if (!profile) return req.reject(404, 'Profil introuvable');
    const user = await SELECT.one.from(Users).where({ ID: profile.user_ID });
    if (!req.user.is('Admin') && user.email !== req.user.id) return req.reject(403);
    const [skills, experiences, educations, certifications, languages] = await Promise.all([
      SELECT.from(Skills).where({ profile_ID: profileId }), SELECT.from(Experiences).where({ profile_ID: profileId }),
      SELECT.from(Educations).where({ profile_ID: profileId }), SELECT.from(Certifications).where({ profile_ID: profileId }),
      SELECT.from(Languages).where({ profile_ID: profileId })
    ]);
    const content = JSON.stringify({ user, profile, skills, experiences, educations, certifications, languages }, null, 2);
    const row = { ID: cds.utils.uuid(), profile_ID: profileId, fileName: `CV-${user.displayName.replace(/\\s+/g,'-')}.json`, generatedAt: new Date().toISOString(), content };
    await INSERT.into(GeneratedCVs).entries(row);
    return row;
  });
});