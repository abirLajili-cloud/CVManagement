using { skillfinder as db } from '../db/schema';

@path: '/odata/v4/skillfinder'
@requires: 'authenticated-user'
service SkillFinderService {
  @restrict: [{ grant: '*', to: 'Admin' }, { grant: 'READ', to: 'User', where: 'user.email = $user' }]
  entity Profiles as projection on db.Profiles;

  @restrict: [{ grant: '*', to: 'Admin' }, { grant: 'READ', to: 'User', where: 'email = $user' }]
  entity Users as projection on db.Users;

  @restrict: [{ grant: '*', to: ['Admin','User'] }]
  entity Skills as projection on db.Skills;
  @restrict: [{ grant: '*', to: ['Admin','User'] }]
  entity Experiences as projection on db.Experiences;
  @restrict: [{ grant: '*', to: ['Admin','User'] }]
  entity Educations as projection on db.Educations;
  @restrict: [{ grant: '*', to: ['Admin','User'] }]
  entity Certifications as projection on db.Certifications;
  @restrict: [{ grant: '*', to: ['Admin','User'] }]
  entity Languages as projection on db.Languages;
  @restrict: [{ grant: '*', to: ['Admin','User'] }]
  entity GeneratedCVs as projection on db.GeneratedCVs;

  type SessionInfo { id: String; role: String; displayName: String; email: String; profileId: UUID; }
  type DashboardStats { users: Integer; profiles: Integer; cvs: Integer; skills: Integer; }

  function me() returns SessionInfo;
  @requires: 'Admin' function dashboardStats() returns DashboardStats;
  @requires: 'Admin' function advancedSearch(skill: String, minYears: Decimal, certification: String) returns array of Profiles;
  @requires: ['Admin','User'] action generateCV(profileId: UUID) returns GeneratedCVs;
}