// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.9.0;

// -----------------------------------
//  ALUMNO   |    ID    |      NOTA
// -----------------------------------
//  Marcos |    77755N    |      5
//  Joan   |    12345X    |      9
//  Maria  |    02468T    |      2
//  Marta  |    13579U    |      3
//  Alba   |    98765Z    |      5

contract Notas {
    // Direccion del profesor
    address public profesor;
    
    // Constructor 
    constructor () {
        profesor = msg.sender;
    }
    
    // Mapping para relacionar el hash de la identidad del alumno con su nota del examen
    mapping (bytes32 => uint) notas;
    
    // Array de los alumnos de pidan revisiones de examen
    string [] revisionesEstudiantes;

    // mapping con el id del estudiante y su estado de revision
    mapping (string => string) revisiones;
    
    // Eventos 
    event alumno_evaluado(bytes32);
    event evento_revision(string);
    event estudianteReevaluado (string);

    // Control de las funciones ejecutables por el profesor
    modifier soloProfesor (address _direccion){
        //validamos que sea la misma address de owner
        require (_direccion == profesor, "No tienes permisos para ejecutar esta funcion.");
        _;
    }

    // Funcion para evaluar alumnos
    function evaluar (string memory _idAlumno, uint _nota) public soloProfesor(msg.sender){
        //Hash con la identificacion del alumno
        bytes32 hash_alumno = keccak256(abi.encodePacked(_idAlumno));

        //Relacion entre el hash alumno y su nota
        notas[hash_alumno] = _nota;
        emit alumno_evaluado(hash_alumno);
    }

    function solicitudRevision(string memory _idAlumno) public {
        //revisiones.push(_idAlumno);
        revisiones[_idAlumno] = 'Pendiente';
        revisionesEstudiantes.push(_idAlumno);
        emit evento_revision(_idAlumno);
    }

    //Funcion solicitudes de estudiantes revisiones
    function revisionesPendientes () public view soloProfesor(msg.sender) returns(string[] memory){
        //nuevo array para guardar los estudiantes que faltan por calificar
        string[] memory pendienteRevision = new string [](revisionesEstudiantes.length);
        uint contador=0;
        for (uint i = 0; i < revisionesEstudiantes.length; i++) {
            if ( keccak256(abi.encodePacked(revisiones[revisionesEstudiantes[i]]))  ==  keccak256(abi.encodePacked("Pendiente"))){
                pendienteRevision[contador] = revisionesEstudiantes[i];
                contador++;
            }
        }
        //deberia retornar el array solo con estudiantes pendientes por revision
        return pendienteRevision;  
    }

    // Funcion para ver las notas de un alumno 
    function VerNotas(string memory _idAlumno) public view returns(uint) {
        // Hash de la identificacion del alumno 
        bytes32 hash_idAlumno = keccak256(abi.encodePacked(_idAlumno));

        // Nota asociada al hash del alumno
        uint nota_alumno = notas[hash_idAlumno];

        // Visualizar la nota 
        return nota_alumno;
    } 

    //funcion reevaluar estudiantes
    function reevaluarEstudiantes (string memory _idAlumno, uint _nota) public soloProfesor(msg.sender) {
        //Hash con la identificacion del alumno
        bytes32 hash_alumno = keccak256(abi.encodePacked(_idAlumno));

        //Relacion entre el hash alumno y su nota
        notas[hash_alumno] = _nota;
        revisiones[_idAlumno] = 'Completado';
        emit alumno_evaluado(hash_alumno);
    }
}