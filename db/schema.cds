namespace skillfinder;
using { cuid, managed } from '@sap/cds/common';

entity Users : cuid, managed {
  email       : String(255) @mandatory;
  displayName : String(160) @mandatory;
  role        : String(10) enum { USER; ADMIN; } default 'USER';
  active      : Boolean default true;
  profile     : Association to one Profiles on profile.user = $self;
}

entity Profiles : cuid, managed {
  user             : Association to one Users @mandatory;
  jobTitle         : String(120);
  department       : String(120);
  phone            : String(40);
  location         : String(120);
  professionalSummary : LargeString;
  totalExperienceYears : Decimal(4,1) default 0;
  profileCompleted : Boolean default false;
  skills           : Composition of many Skills on skills.profile = $self;
  experiences      : Composition of many Experiences on experiences.profile = $self;
  educations       : Composition of many Educations on educations.profile = $self;
  certifications   : Composition of many Certifications on certifications.profile = $self;
  languages        : Composition of many Languages on languages.profile = $self;
  cvs              : Composition of many GeneratedCVs on cvs.profile = $self;
}

entity Skills : cuid, managed {
  profile         : Association to one Profiles @mandatory;
  name            : String(120) @mandatory;
  level           : String(30) enum { Debutant; Intermediaire; Avance; Expert; };
  experienceYears : Decimal(4,1) default 0;
}

entity Experiences : cuid, managed {
  profile     : Association to one Profiles @mandatory;
  company     : String(150) @mandatory;
  title       : String(150) @mandatory;
  startDate   : Date @mandatory;
  endDate     : Date;
  currentRole : Boolean default false;
  technologies: String(500);
  description : LargeString;
}

entity Educations : cuid, managed {
  profile     : Association to one Profiles @mandatory;
  institution : String(180) @mandatory;
  degree      : String(180) @mandatory;
  field       : String(180);
  startDate   : Date;
  endDate     : Date;
}

entity Certifications : cuid, managed {
  profile      : Association to one Profiles @mandatory;
  name         : String(180) @mandatory;
  issuer       : String(180);
  issueDate    : Date;
  expirationDate : Date;
  credentialId : String(120);
  credentialUrl: String(500);
}

entity Languages : cuid, managed {
  profile : Association to one Profiles @mandatory;
  name    : String(80) @mandatory;
  level   : String(40) @mandatory;
}

entity GeneratedCVs : cuid, managed {
  profile      : Association to one Profiles @mandatory;
  fileName     : String(255);
  generatedAt  : Timestamp;
  content      : LargeString;
}
