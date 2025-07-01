# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class CreditClaim(models.Model):
    claim_date = models.DateField()
    claim_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    description = models.TextField()
    status = models.CharField(max_length=8)
    policy = models.ForeignKey('CreditPolicy', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Credit_claim'


class CreditClient(models.Model):
    client_id = models.CharField(max_length=100)
    name = models.CharField(max_length=100)
    surname = models.CharField(max_length=100)
    email = models.CharField(max_length=254)
    initials = models.CharField(max_length=10)
    id_number = models.CharField(max_length=100)
    dob = models.DateField()
    gender = models.CharField(max_length=10)
    address = models.CharField(max_length=255)
    city_state_zip = models.CharField(max_length=255)
    smoker_status = models.CharField(max_length=10)

    class Meta:
        managed = False
        db_table = 'Credit_client'


class CreditCollections(models.Model):
    payment_date = models.DateField()
    premium = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    status = models.CharField(max_length=10)
    description = models.TextField(blank=True, null=True)
    policy = models.ForeignKey('CreditPolicy', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Credit_collections'


class CreditInsurer(models.Model):
    name = models.CharField(max_length=100)
    contact_details = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'Credit_insurer'


class CreditNotes(models.Model):
    query = models.TextField()
    created_at = models.DateTimeField()
    client = models.ForeignKey(CreditClient, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Credit_notes'


class CreditPoliciesNew(models.Model):
    insurer = models.CharField(db_column='Insurer', max_length=100)  # Field name made lowercase.
    policypk = models.AutoField(db_column='PolicyPk', primary_key=True)  # Field name made lowercase.
    personaid = models.IntegerField(db_column='Personaid')  # Field name made lowercase.
    clientid = models.IntegerField(db_column='ClientID')  # Field name made lowercase.
    policydoc = models.DateField(db_column='PolicyDOC')  # Field name made lowercase.
    dob = models.DateField(db_column='DOB')  # Field name made lowercase.
    gender = models.CharField(db_column='Gender', max_length=100)  # Field name made lowercase.
    smokerstatus = models.CharField(db_column='Smokerstatus', max_length=100)  # Field name made lowercase.
    package_pk = models.IntegerField(db_column='Package_pk')  # Field name made lowercase.
    benefit_pk = models.IntegerField(db_column='Benefit_pk')  # Field name made lowercase.
    premium = models.DecimalField(db_column='Premium', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    net_to_broker = models.DecimalField(db_column='Net_to_broker', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    net_to_fmi = models.DecimalField(db_column='Net_to_fmi', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    package = models.CharField(db_column='Package', max_length=100)  # Field name made lowercase.
    product_group = models.CharField(db_column='Product_group', max_length=100)  # Field name made lowercase.
    benefit_group = models.CharField(db_column='Benefit_group', max_length=100)  # Field name made lowercase.
    benefit_name = models.CharField(db_column='Benefit_name', max_length=100)  # Field name made lowercase.
    benefit_subgroup = models.CharField(db_column='Benefit_subgroup', max_length=100)  # Field name made lowercase.
    cover_amount = models.DecimalField(db_column='Cover_amount', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    occupation = models.CharField(db_column='Occupation', max_length=100)  # Field name made lowercase.
    occupationclass = models.DecimalField(db_column='OccupationClass', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    annualsalary = models.DecimalField(db_column='AnnualSalary', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    education = models.CharField(db_column='Education', max_length=100)  # Field name made lowercase.
    socialeconomicclass = models.CharField(db_column='SocialEconomicClass', max_length=100)  # Field name made lowercase.
    commstructure = models.CharField(db_column='CommStructure', max_length=100)  # Field name made lowercase.
    ceaseage = models.IntegerField(db_column='CeaseAge')  # Field name made lowercase.
    benefitterm = models.DecimalField(db_column='BenefitTerm', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    prempattern = models.CharField(db_column='PremPattern', max_length=100)  # Field name made lowercase.
    benefitescalation = models.DecimalField(db_column='BenefitEscalation', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    claimsescalation = models.DecimalField(db_column='ClaimsEscalation', max_digits=10, decimal_places=5)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    level_term_chosen = models.BooleanField(db_column='Level_Term_chosen')  # Field name made lowercase.
    claim_payment_frequency = models.CharField(db_column='Claim_Payment_Frequency', max_length=100)  # Field name made lowercase.
    cover_amount_is_per = models.CharField(db_column='Cover_Amount_is_per', max_length=100)  # Field name made lowercase.
    ownocc_or_ownsimilarocc = models.CharField(db_column='OwnOcc_or_OwnSimilarOcc', max_length=100)  # Field name made lowercase.
    accident = models.CharField(db_column='Accident', max_length=100)  # Field name made lowercase.
    ill = models.CharField(db_column='Ill', max_length=100)  # Field name made lowercase.
    waiting_period = models.CharField(db_column='Waiting_Period', max_length=100)  # Field name made lowercase.
    deferment_accident = models.CharField(db_column='Deferment_Accident', max_length=100)  # Field name made lowercase.
    deferment_illness = models.CharField(db_column='Deferment_Illness', max_length=100)  # Field name made lowercase.
    status_indicator = models.CharField(db_column='Status_indicator', max_length=100)  # Field name made lowercase.
    excessperiod_illness = models.CharField(db_column='ExcessPeriod_Illness', max_length=100)  # Field name made lowercase.
    excessperiod_accident = models.CharField(db_column='ExcessPeriod_Accident', max_length=100)  # Field name made lowercase.
    retrospectivepayments = models.CharField(db_column='RetrospectivePayments', max_length=100)  # Field name made lowercase.
    status_indicator_monthly = models.CharField(db_column='Status_indicator_Monthly', max_length=100)  # Field name made lowercase.
    minimun_benefit_doc = models.DateField(db_column='MInimun_Benefit_DOC')  # Field name made lowercase.
    policyholder = models.CharField(db_column='Policyholder', max_length=100)  # Field name made lowercase.
    spouse = models.CharField(db_column='Spouse', max_length=100)  # Field name made lowercase.
    dependants = models.CharField(db_column='Dependants', max_length=100)  # Field name made lowercase.
    max_floadingpercenage = models.CharField(db_column='Max_fLoadingPercenage', max_length=100)  # Field name made lowercase.
    wholelife = models.CharField(db_column='WholeLife', max_length=100)  # Field name made lowercase.
    claimguarantee = models.CharField(db_column='ClaimGuarantee', max_length=100, blank=True, null=True)  # Field name made lowercase.
    pdesex = models.CharField(db_column='PDeSex', max_length=100, blank=True, null=True)  # Field name made lowercase.
    pdebob = models.DateField(db_column='PDeBOB', blank=True, null=True)  # Field name made lowercase.
    child_protector_age = models.IntegerField(db_column='Child_Protector_Age', blank=True, null=True)  # Field name made lowercase.
    grouporindiv = models.CharField(db_column='GrouporIndiv', max_length=100)  # Field name made lowercase.
    event_class = models.CharField(db_column='Event_Class', max_length=100)  # Field name made lowercase.
    adminormanual = models.CharField(db_column='AdminOrManual', max_length=100)  # Field name made lowercase.
    healthclass = models.CharField(db_column='HealthClass', max_length=100)  # Field name made lowercase.
    occupation_id = models.IntegerField(db_column='Occupation_ID')  # Field name made lowercase.
    pdeintno = models.DecimalField(db_column='PDeIntNo', max_digits=10, decimal_places=5, blank=True, null=True)  # Field name made lowercase. max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    client_surname = models.CharField(db_column='Client_Surname', max_length=100)  # Field name made lowercase.
    client_initials = models.CharField(db_column='Client_Initials', max_length=100)  # Field name made lowercase.
    client_firstname = models.CharField(db_column='Client_FirstName', max_length=100)  # Field name made lowercase.
    client_idnumber = models.CharField(db_column='Client_IDNumber', max_length=100)  # Field name made lowercase.
    pdesurname = models.CharField(db_column='PDESURNAME', max_length=100)  # Field name made lowercase.
    pdeinitials = models.CharField(db_column='PDEINITIALS', max_length=100)  # Field name made lowercase.
    pdeidno = models.CharField(db_column='PDEIDNO', max_length=100)  # Field name made lowercase.
    pdefirstnames = models.CharField(db_column='PDEFIRSTNAMES', max_length=100)  # Field name made lowercase.
    top_up = models.CharField(db_column='TOP_UP', max_length=100)  # Field name made lowercase.
    claim_extender = models.CharField(db_column='CLAIM_EXTENDER', max_length=100)  # Field name made lowercase.
    occ_life_loadings = models.CharField(db_column='Occ_Life_Loadings', max_length=100, blank=True, null=True)  # Field name made lowercase.
    abi_cpi_indicator = models.CharField(db_column='ABI_CPI_Indicator', max_length=100)  # Field name made lowercase.
    manually_increased_cover = models.CharField(db_column='Manually_Increased_Cover', max_length=100)  # Field name made lowercase.
    manually_increased_premium = models.CharField(db_column='Manually_Increased_Premium', max_length=100)  # Field name made lowercase.
    additions_indicator = models.CharField(db_column='Additions_Indicator', max_length=100)  # Field name made lowercase.
    frozen_indicator = models.CharField(db_column='Frozen_Indicator', max_length=100)  # Field name made lowercase.
    commutation = models.CharField(db_column='Commutation', max_length=100)  # Field name made lowercase.
    brokercommtoclient = models.CharField(db_column='BROKERCOMMTOCLIENT', max_length=100)  # Field name made lowercase.
    brokercommasandwhen = models.CharField(db_column='BROKERCOMMASANDWHEN', max_length=100)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Credit_policies_new'


class CreditPolicy(models.Model):
    policy_pk = models.CharField(unique=True, max_length=100)
    person_aid = models.CharField(max_length=100)
    premium = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    net_to_broker = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    net_to_fmi = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    package = models.CharField(max_length=100)
    benefit_group = models.CharField(max_length=100)
    benefit_name = models.CharField(max_length=100)
    benefit_subgroup = models.CharField(max_length=100)
    cover_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    occupation = models.CharField(max_length=100)
    occupation_class = models.CharField(max_length=100)
    annual_salary = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    cease_age = models.IntegerField()
    benefit_term = models.IntegerField()
    benefit_escalation = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    claims_escalation = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    level_term_chosen = models.BooleanField()
    accident = models.BooleanField()
    illness = models.BooleanField()
    waiting_period_illness = models.IntegerField()
    deferment_accident = models.IntegerField()
    deferment_illness = models.IntegerField()
    status_indicator_financial_year = models.CharField(max_length=100)
    retrospective_payment = models.BooleanField()
    status_indicator_monthly = models.CharField(max_length=100)
    policyholder = models.CharField(max_length=100)
    spouse = models.CharField(max_length=100)
    dependant = models.CharField(max_length=100)
    max_f_loading_percentage = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    claim_guarantee = models.BooleanField()
    pde_sex = models.CharField(max_length=10)
    pde_dob = models.DateField()
    child_protector_age = models.IntegerField()
    event_class = models.CharField(max_length=100)
    admin_or_manual = models.CharField(max_length=100)
    health_class = models.CharField(max_length=100)
    occupation_id = models.CharField(max_length=100)
    pde_int_no = models.CharField(max_length=100)
    top_up = models.BooleanField()
    claim_extender = models.BooleanField()
    abi_cpi_indicator = models.BooleanField()
    manually_increased_cover = models.BooleanField()
    manually_increased_premium = models.BooleanField()
    additions_indicator = models.BooleanField()
    frozen_indicator = models.BooleanField()
    commutation = models.BooleanField()
    broker_comm_to_client = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    broker_comm_as_and_when = models.CharField(max_length=100)
    insurer_listing = models.CharField(max_length=100)
    flag = models.CharField(max_length=100)
    classification = models.CharField(max_length=100)
    benefit_frequency = models.CharField(max_length=100)
    fk_can_reasons = models.CharField(max_length=100)
    can_reasons = models.CharField(max_length=100)
    dt_last_premium = models.DateField()
    file_date = models.DateField()
    reinstatement_date = models.DateField()
    closing_premium = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    closing_cover_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    manual_increase_date = models.DateField()
    cancel_date_reinstatements = models.DateField()
    client = models.ForeignKey(CreditClient, models.DO_NOTHING)
    insurer = models.ForeignKey(CreditInsurer, models.DO_NOTHING)
    benefit_code = models.CharField(max_length=100)
    group_or_individual = models.CharField(max_length=100)
    minimum_benefit_document_date = models.DateField()
    package_code = models.CharField(max_length=100)
    policy_document_date = models.DateField()
    whole_of_life = models.BooleanField()

    class Meta:
        managed = False
        db_table = 'Credit_policy'


class CustomersupportChildpricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'CustomerSupport_childpricingmodel'


class CustomersupportClaimform(models.Model):
    title = models.CharField(max_length=100)
    form_file = models.CharField(max_length=100)
    insurance_type = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'CustomerSupport_claimform'


class CustomersupportComplaint(models.Model):
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=254)
    message = models.TextField()
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'CustomerSupport_complaint'


class CustomersupportExtendedfamilypricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'CustomerSupport_extendedfamilypricingmodel'


class CustomersupportIndividualpricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'CustomerSupport_individualpricingmodel'


class CustomersupportSpousepricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'CustomerSupport_spousepricingmodel'


class FuneralChildpricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'Funeral_childpricingmodel'


class FuneralClaim(models.Model):
    claim_status = models.CharField(max_length=50)
    claim_date = models.DateField()
    claimant = models.CharField(max_length=50)
    claim_amount = models.DecimalField(max_digits=10, decimal_places=5, blank=True, null=True)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    claim_form = models.CharField(max_length=100)
    death_certificate = models.CharField(max_length=100)
    policy_document = models.CharField(max_length=100)
    client = models.ForeignKey('FuneralClients', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Funeral_claim'


class FuneralClaimnotes(models.Model):
    document = models.CharField(max_length=100)
    uploaded_at = models.DateTimeField()
    claim = models.ForeignKey(FuneralClaim, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Funeral_claimnotes'


class FuneralClients(models.Model):
    policy_number = models.PositiveBigIntegerField(primary_key=True)
    risk_uuid = models.PositiveBigIntegerField(unique=True)
    status = models.CharField(max_length=100)
    email = models.CharField(max_length=254)
    phone_number = models.CharField(max_length=15)
    policy_commencement_date = models.DateField(db_column='Policy_Commencement_Date')  # Field name made lowercase.
    main_member_name = models.CharField(db_column='Main_Member_Name', max_length=100)  # Field name made lowercase.
    main_member_last_name = models.CharField(db_column='Main_Member_Last_Name', max_length=100)  # Field name made lowercase.
    birth_date = models.DateField()
    gender = models.CharField(max_length=10)
    cover_amount = models.CharField(db_column='cover_Amount', max_length=10)  # Field name made lowercase.
    occupation = models.CharField(max_length=100)
    identity_no = models.CharField(max_length=100)
    relationship = models.CharField(max_length=100)
    id_document = models.CharField(max_length=100, blank=True, null=True)
    policy_application = models.CharField(max_length=100, blank=True, null=True)
    proof_of_income = models.CharField(max_length=100, blank=True, null=True)
    proof_of_residence = models.CharField(max_length=100, blank=True, null=True)
    spouse_uuid = models.PositiveBigIntegerField(unique=True)
    spouce_first_names = models.CharField(db_column='Spouce_First_Names', max_length=100, blank=True, null=True)  # Field name made lowercase.
    spouse_identity_no = models.CharField(max_length=100, blank=True, null=True)
    spouse_birth_date = models.DateField(blank=True, null=True)
    spouse_gender = models.CharField(max_length=10, blank=True, null=True)
    spouse_coveramount = models.CharField(max_length=10, blank=True, null=True)
    spouce_id = models.CharField(max_length=100, blank=True, null=True)
    marriage_certificate = models.CharField(max_length=100, blank=True, null=True)
    spouse_identity_no2 = models.CharField(max_length=100, blank=True, null=True)
    spouce_name2 = models.CharField(db_column='Spouce_Name2', max_length=100)  # Field name made lowercase.
    spouse_birth_date2 = models.DateField(blank=True, null=True)
    spouse_gender2 = models.CharField(max_length=10, blank=True, null=True)
    spouse_coveramount2 = models.CharField(max_length=10, blank=True, null=True)
    spouce_id_2 = models.CharField(max_length=100, blank=True, null=True)
    marriage_certificate2 = models.CharField(max_length=100, blank=True, null=True)
    child_uuid = models.PositiveBigIntegerField(unique=True)
    child_identity_no = models.CharField(max_length=100, blank=True, null=True)
    child_first_name = models.CharField(db_column='Child_First_Name', max_length=100)  # Field name made lowercase.
    child_last_name = models.CharField(db_column='Child_Last_Name', max_length=100)  # Field name made lowercase.
    child_birth_date = models.DateField(blank=True, null=True)
    child_gender = models.CharField(max_length=10, blank=True, null=True)
    child_coveramount = models.CharField(max_length=10, blank=True, null=True)
    child_identity_n2 = models.CharField(max_length=100, blank=True, null=True)
    child_first_name2 = models.CharField(db_column='Child_First_Name2', max_length=100)  # Field name made lowercase.
    child_last_name2 = models.CharField(db_column='Child_Last_Name2', max_length=100)  # Field name made lowercase.
    child_birth_date2 = models.DateField(blank=True, null=True)
    child_gender2 = models.CharField(max_length=10, blank=True, null=True)
    child_coveramount2 = models.CharField(max_length=10, blank=True, null=True)
    birth_certificate = models.CharField(max_length=100, blank=True, null=True)
    child_identity_no3 = models.CharField(max_length=100, blank=True, null=True)
    child_first_name3 = models.CharField(db_column='Child_First_Name3', max_length=100)  # Field name made lowercase.
    child_last_name3 = models.CharField(db_column='Child_Last_Name3', max_length=100)  # Field name made lowercase.
    child_birth_date3 = models.DateField(blank=True, null=True)
    child_gender3 = models.CharField(max_length=10, blank=True, null=True)
    child_coveramount3 = models.CharField(max_length=10, blank=True, null=True)
    birth_certificate3 = models.CharField(max_length=100, blank=True, null=True)
    child_identity_no4 = models.CharField(max_length=100, blank=True, null=True)
    child_first_name4 = models.CharField(db_column='Child_First_Name4', max_length=100)  # Field name made lowercase.
    child_last_name4 = models.CharField(db_column='Child_Last_Name4', max_length=100)  # Field name made lowercase.
    child_birth_date4 = models.DateField(blank=True, null=True)
    child_gender4 = models.CharField(max_length=10, blank=True, null=True)
    child_coveramount4 = models.CharField(max_length=10, blank=True, null=True)
    birth_certificate4 = models.CharField(max_length=100, blank=True, null=True)
    child_identity_no5 = models.CharField(max_length=100, blank=True, null=True)
    child_first_name5 = models.CharField(db_column='Child_First_Name5', max_length=100)  # Field name made lowercase.
    child_last_name5 = models.CharField(db_column='Child_Last_Name5', max_length=100)  # Field name made lowercase.
    child_birth_date5 = models.DateField(blank=True, null=True)
    child_gender5 = models.CharField(max_length=10, blank=True, null=True)
    child_coveramount5 = models.CharField(max_length=10, blank=True, null=True)
    birth_certificate5 = models.CharField(max_length=100, blank=True, null=True)
    extended_family_uuid = models.PositiveBigIntegerField(unique=True)
    extended_identity_no = models.CharField(max_length=100, blank=True, null=True)
    extended_first_name = models.CharField(db_column='extended_First_Name', max_length=100)  # Field name made lowercase.
    extended_last_name = models.CharField(db_column='extended_Last_Name', max_length=100)  # Field name made lowercase.
    extended_family_birth_date = models.DateField(blank=True, null=True)
    extended_family_gender = models.CharField(max_length=10, blank=True, null=True)
    extended_family_coveramount = models.CharField(max_length=10, blank=True, null=True)
    id_extended = models.CharField(max_length=100, blank=True, null=True)
    extended_identity_no2 = models.CharField(max_length=100, blank=True, null=True)
    extended_first_name2 = models.CharField(db_column='extended_First_Name2', max_length=100)  # Field name made lowercase.
    extended_last_name2 = models.CharField(db_column='extended_Last_Name2', max_length=100)  # Field name made lowercase.
    extended_family_birth_date2 = models.DateField(blank=True, null=True)
    extended_family_gender2 = models.CharField(max_length=10, blank=True, null=True)
    extended_family_coveramount2 = models.CharField(max_length=10, blank=True, null=True)
    id_extended2 = models.CharField(max_length=100, blank=True, null=True)
    extended_identity_no3 = models.CharField(max_length=100, blank=True, null=True)
    extended_first_name3 = models.CharField(db_column='extended_First_Name3', max_length=100)  # Field name made lowercase.
    extended_last_name3 = models.CharField(db_column='extended_Last_Name3', max_length=100)  # Field name made lowercase.
    extended_family_birth_date3 = models.DateField(blank=True, null=True)
    extended_family_gender3 = models.CharField(max_length=10, blank=True, null=True)
    extended_family_coveramount3 = models.CharField(max_length=10, blank=True, null=True)
    id_extended3 = models.CharField(max_length=100, blank=True, null=True)
    extended_identity_no4 = models.CharField(max_length=100, blank=True, null=True)
    extended_first_name4 = models.CharField(db_column='extended_First_Name4', max_length=100)  # Field name made lowercase.
    extended_last_name4 = models.CharField(db_column='extended_Last_Name4', max_length=100)  # Field name made lowercase.
    extended_family_birth_date4 = models.DateField(blank=True, null=True)
    extended_family_gender4 = models.CharField(max_length=10, blank=True, null=True)
    extended_family_coveramount4 = models.CharField(max_length=10, blank=True, null=True)
    id_extended4 = models.CharField(max_length=100, blank=True, null=True)
    extended_identity_no5 = models.CharField(max_length=100, blank=True, null=True)
    extended_first_name5 = models.CharField(db_column='extended_First_Name5', max_length=100)  # Field name made lowercase.
    extended_last_name5 = models.CharField(db_column='extended_Last_Name5', max_length=100)  # Field name made lowercase.
    extended_family_birth_date5 = models.DateField(blank=True, null=True)
    extended_family_gender5 = models.CharField(max_length=10, blank=True, null=True)
    extended_family_coveramount5 = models.CharField(max_length=10, blank=True, null=True)
    id_extended5 = models.CharField(max_length=100, blank=True, null=True)
    notes = models.TextField(db_column='Notes')  # Field name made lowercase.
    birth_certificate2 = models.CharField(max_length=100, blank=True, null=True)
    spouce_last_names = models.CharField(db_column='spouce_Last_Names', max_length=100, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Funeral_clients'


class FuneralClientsnotes(models.Model):
    document = models.CharField(max_length=100)
    uploaded_at = models.DateTimeField()
    clients = models.ForeignKey(FuneralClients, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Funeral_clientsnotes'


class FuneralCollections(models.Model):
    payment_date = models.DateField(blank=True, null=True)
    payment_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    payment_status = models.CharField(max_length=20)
    payment_method = models.CharField(max_length=20, blank=True, null=True)
    payment_reference_number = models.PositiveBigIntegerField(unique=True)
    client = models.ForeignKey(FuneralClients, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Funeral_collections'


class FuneralExtendedfamilypricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'Funeral_extendedfamilypricingmodel'


class FuneralIndividualpricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'Funeral_individualpricingmodel'


class FuneralPricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'Funeral_pricingmodel'


class FuneralSpousepricingmodel(models.Model):
    age_range = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    relationship = models.CharField(max_length=20)
    cover_amount = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float

    class Meta:
        managed = False
        db_table = 'Funeral_spousepricingmodel'


class HealthClaim(models.Model):
    claim_date = models.DateField()
    claim_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    description = models.TextField()
    status = models.CharField(max_length=20)
    date_settled = models.DateField(blank=True, null=True)
    policy = models.ForeignKey('HealthPolicy', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Health_claim'


class HealthClient(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    id_number = models.CharField(unique=True, max_length=100)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=10)
    marital_status = models.CharField(max_length=20)
    address = models.TextField()
    phone_number = models.CharField(max_length=15)
    email = models.CharField(max_length=254)

    class Meta:
        managed = False
        db_table = 'Health_client'


class HealthCoverage(models.Model):
    coverage_type = models.CharField(max_length=100)
    coverage_limit = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    deductible = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    policy = models.ForeignKey('HealthPolicy', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Health_coverage'


class HealthDocument(models.Model):
    document_type = models.CharField(max_length=100)
    file = models.CharField(max_length=100)
    uploaded_at = models.DateTimeField()
    client = models.ForeignKey(HealthClient, models.DO_NOTHING)
    version = models.PositiveIntegerField()

    class Meta:
        managed = False
        db_table = 'Health_document'


class HealthPayment(models.Model):
    payment_date = models.DateField()
    amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    payment_method = models.CharField(max_length=50)
    policy = models.ForeignKey('HealthPolicy', models.DO_NOTHING)
    status = models.CharField(max_length=20)
    reference_number = models.CharField(unique=True, max_length=100)

    class Meta:
        managed = False
        db_table = 'Health_payment'


class HealthPolicy(models.Model):
    policy_number = models.CharField(unique=True, max_length=100)
    start_date = models.DateField()
    end_date = models.DateField()
    premium_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    coverage_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    policy_type = models.CharField(max_length=50)
    renewal_date = models.DateField(blank=True, null=True)
    client = models.ForeignKey(HealthClient, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Health_policy'


class MotorClaim(models.Model):
    claim_id = models.PositiveBigIntegerField(unique=True)
    claim_date = models.DateField(blank=True, null=True)
    claim_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    description = models.TextField()
    client = models.ForeignKey('MotorClient', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Motor_claim'


class MotorClient(models.Model):
    policy_number = models.PositiveBigIntegerField(primary_key=True)
    name = models.CharField(max_length=100)
    surname = models.CharField(max_length=100)
    idnumber = models.CharField(db_column='idNumber', unique=True, max_length=100)  # Field name made lowercase.
    age = models.PositiveIntegerField()
    gender = models.CharField(max_length=10)
    marital_status = models.CharField(max_length=10)
    occupation = models.CharField(max_length=100)
    annual_income = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    location = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'Motor_client'


class MotorClientdata(models.Model):
    file = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'Motor_clientdata'


class MotorCollections(models.Model):
    payment_date = models.DateField(blank=True, null=True)
    payment_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    payment_status = models.CharField(max_length=20)
    payment_method = models.CharField(max_length=20)
    payment_reference_number = models.PositiveBigIntegerField(unique=True)
    client = models.ForeignKey(MotorClient, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Motor_collections'


class MotorMotorinsurance(models.Model):
    start_date = models.DateField()
    end_date = models.DateField()
    premium_amount = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    policy_status = models.CharField(max_length=20)
    client = models.ForeignKey(MotorClient, models.DO_NOTHING)
    vehicle = models.ForeignKey('MotorVehicle', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Motor_motorinsurance'


class MotorVehicle(models.Model):
    reg_number = models.CharField(max_length=12)
    make = models.CharField(max_length=50)
    model = models.CharField(max_length=50)
    year = models.PositiveIntegerField()
    value = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    driving_experience = models.PositiveIntegerField()
    accident_history = models.TextField()
    claim_history = models.TextField()
    client = models.ForeignKey(MotorClient, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Motor_vehicle'


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)
    name = models.CharField(max_length=255)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()
    first_name = models.CharField(max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.PositiveSmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    action_time = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'
