pragma solidity ^0.8.0;

contract MedicalRecord {
    struct Record {
        string patientName;
        string diagnosis;
        uint date;
    }

    mapping(address => Record[]) public medicalRecords;
    mapping(address => bool) public authorizedDoctors;

    event RecordAdded(address indexed patient, string patientName, string diagnosis, uint date);
    event RecordUpdated(address indexed patient, uint recordIndex, string diagnosis);
    event RecordDeleted(address indexed patient, uint recordIndex);
    event DoctorAuthorized(address indexed doctor);
    event DoctorRevoked(address indexed doctor);

    modifier onlyDoctor() {
        require(authorizedDoctors[msg.sender], "Only authorized doctors can perform this action.");
        _;
    }

    function addRecord(string memory patientName, string memory diagnosis) public {
        Record memory newRecord = Record({
            patientName: patientName,
            diagnosis: diagnosis,
            date: block.timestamp
        });

        medicalRecords[msg.sender].push(newRecord);
        emit RecordAdded(msg.sender, patientName, diagnosis, block.timestamp);
    }

    function updateRecord(uint recordIndex, string memory newDiagnosis) public {
        require(recordIndex < medicalRecords[msg.sender].length, "Record does not exist.");

        require(authorizedDoctors[msg.sender] || msg.sender == msg.sender, "You are not allowed to modify this record.");

        medicalRecords[msg.sender][recordIndex].diagnosis = newDiagnosis;
        emit RecordUpdated(msg.sender, recordIndex, newDiagnosis);
    }



    function deleteRecord(uint recordIndex) public {
        require(recordIndex < medicalRecords[msg.sender].length, "Record does not exist.");
        for (uint i = recordIndex; i < medicalRecords[msg.sender].length - 1; i++) {
            medicalRecords[msg.sender][i] = medicalRecords[msg.sender][i + 1];
        }
        medicalRecords[msg.sender].pop();
        emit RecordDeleted(msg.sender, recordIndex);
    }

    function getRecords() public view returns (Record[] memory) {
        return medicalRecords[msg.sender];
    }

    function getRecordsByPatientName(string memory patientName) public view returns (Record[] memory) {
        Record[] memory patientRecords = new Record[](medicalRecords[msg.sender].length);
        uint count = 0;

        for (uint i = 0; i < medicalRecords[msg.sender].length; i++) {
            if (keccak256(abi.encodePacked(medicalRecords[msg.sender][i].patientName)) == keccak256(abi.encodePacked(patientName))) {
                patientRecords[count] = medicalRecords[msg.sender][i];
                count++;
            }
        }

        bytes memory encoded = abi.encode(patientRecords);
        assembly {
            mstore(add(encoded, 0x40), count)
        }

        return patientRecords;
    }

    function authorizeDoctor(address doctor) public {
        authorizedDoctors[doctor] = true;
        emit DoctorAuthorized(doctor);
    }

    function revokeDoctor(address doctor) public {
        authorizedDoctors[doctor] = false;
        emit DoctorRevoked(doctor);
    }
}
