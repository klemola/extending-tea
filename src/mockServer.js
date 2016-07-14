const Express = require('express');
const Session = require('express-session');
const BodyParser = require('body-parser');
const CookieParser = require('cookie-parser');
const Uuid = require('node-uuid');

const app = Express();
const ApiRouter = Express.Router();

const cookieConfig = {
  secure: false,
  httpOnly: true,
  expires: 1000 * 60 * 60,
};

const sessionConfig = {
  name: 'extea-session',
  secret: 'supersecret',
  resave: false,
  saveUninitialized: true,
  cookie: cookieConfig,
  genid: Uuid.v4,
};

let userData = {
  id: Uuid.v4(),
  firstName: 'Eric',
  lastName: 'Example',
  username: 'mycupoftea',
  profilePicture: 'http://placekitten.com/400/400',
  age: 30,
};

const sessions = {};

function isValid(credentials) {
  return !!credentials
    && credentials.username === 'mycupoftea'
    && credentials.password === 'hunter2';
}

function invalidSessionResponse(res) {
  return res
    .status(401)
    .json({ error: 'Invalid session' });
}

function validateSession(req, res, next) {
  if (!req.session || !req.session.id) {
    return invalidSessionResponse(res);
  }

  return next();
}

ApiRouter.post('/login', (req, res) => {
  if (isValid(req.body)) {
    sessions[req.session.id] = userData.id;
    return res.json(userData);
  }

  return res
    .status(400)
    .json({ error: 'Invalid username or password' });
});

ApiRouter.post('/logout', (req, res) => {
  if (req.session && req.session.id) {
    sessions[req.session.id] = null;
  }

  return res.json({ message: 'Session terminated '});
});

ApiRouter.get('/me', validateSession, (req, res) => {
  const userId = req.session ? sessions[req.session.id] : null;

  if (userId)  {
    return res.json(userData);
  }

  return invalidSessionResponse(res);
});

ApiRouter.put('/update', validateSession, (req, res) => {
  const update = req.body;
  console.log(update);
  if (!update) {
    return res
      .status(400)
      .json( {error: 'Invalid request body'} );
  }

  userData = update;
  return res.json(update);
});

app.use(Session(sessionConfig));
app.use(BodyParser.json());
app.use(CookieParser());

app.use('/', Express.static('dist'));
app.use('/api', ApiRouter);

app.listen(9000);
console.log('Mock server started');
