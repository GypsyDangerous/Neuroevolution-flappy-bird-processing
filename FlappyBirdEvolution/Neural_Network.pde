float sigmoid(float x)
{
  return 1 / (1+(float)Math.exp(-x));
}

float dsigmoid(float y)
{
  return y * (1-y);
}

float tanh(float x)
{
  float y = (float) Math.tanh(x);
  return y;
}

float dtanh(float x) 
{
  float y = 1 / (pow((float) Math.cosh(x), 2));
  return y;
}

class NeuralNetwork
{
  int 
    inputNodes, 
    hiddenNodes, 
    outputNodes;

  float LearningRate = .1;

  Matrix 
    IHWeights, 
    HOWeights, 
    Hbias, 
    Obias, 
    input, 
    hidden, 
    output;

  NeuralNetwork(NeuralNetwork copy)
  {
    inputNodes = copy.inputNodes;
    hiddenNodes = copy.hiddenNodes;
    outputNodes = copy.outputNodes;

    IHWeights = copy.IHWeights;
    HOWeights = copy.HOWeights;
    Hbias = copy.Hbias;
    Obias = copy.Obias;
  }

  NeuralNetwork(int input, int hidden, int output)
  {
    inputNodes = input;
    hiddenNodes = hidden;
    outputNodes = output;

    IHWeights = Matrix.Random(hiddenNodes, inputNodes);
    HOWeights = Matrix.Random(outputNodes, hiddenNodes);
    Hbias = Matrix.Random(hiddenNodes, 1);
    Obias = Matrix.Random(outputNodes, 1);
  }

  NeuralNetwork(int input, int hidden, int output, float lr)
  {
    this(input, hidden, output);
    setLearingrate(lr);
  }

  NeuralNetwork copy()
  {
    return new NeuralNetwork(this);
  }


  float mut(float val, float rate)
  {
    if (random(1) < rate)
    {
      return val+randomGaussian()*.1;
    } else
    {
      return val;
    }
  }

  void mutate(float rate)
  {
    for (int i = 0; i < IHWeights.rows; i++)
    {
      for (int j = 0; j < IHWeights.cols; j++)
      {
        float val = IHWeights.values[i][j];
        IHWeights.values[i][j] = mut(val, rate);
      }
    }
    
    for (int i = 0; i < HOWeights.rows; i++)
    {
      for (int j = 0; j < HOWeights.cols; j++)
      {
        float val = HOWeights.values[i][j];
        HOWeights.values[i][j] = mut(val, rate);
      }
    }
    
    for (int i = 0; i < Hbias.rows; i++)
    {
      for (int j = 0; j < Hbias.cols; j++)
      {
        float val = Hbias.values[i][j];
        Hbias.values[i][j] = mut(val, rate);
      }
    }
    
    for (int i = 0; i < Obias.rows; i++)
    {
      for (int j = 0; j < Obias.cols; j++)
      {
        float val = Obias.values[i][j];
        Obias.values[i][j] = mut(val, rate);
      }
    }
  }

  void setLearingrate(float rate)
  {
    LearningRate = rate;
  }

  float[] feedforward(float[] inputArray)
  {
    input = Matrix.FromArray(inputArray);

    //generating hidden inputs
    hidden = Matrix.Product(IHWeights, input);
    hidden.add(Hbias);

    //activation function for hidden nodes!
    for (int i = 0; i < hidden.rows; i++)
    {
      for (int j = 0; j < hidden.cols; j++)
      {
        float val = hidden.values[i][j];
        hidden.values[i][j] = sigmoid(val);
      }
    }

    //generating hidden output
    output = Matrix.Product(HOWeights, hidden);
    output.add(Obias);

    //activation function for ouput nodes!
    for (int i = 0; i < output.rows; i++)
    {
      for (int j = 0; j < output.cols; j++)
      {
        float val = output.values[i][j];
        output.values[i][j] = sigmoid(val);
      }
    }

    //generating the output array
    return output.toArray();
  }

  void train(float[] inputArray, float[] targetArray)
  {
    feedforward(inputArray);

    Matrix targets = Matrix.FromArray(targetArray);
    Matrix outputErrors = Matrix.subtract(targets, output);

    //java version of matrix map function
    Matrix gradient = output.copy();
    for (int i = 0; i < gradient.rows; i++)
    {
      for (int j = 0; j < gradient.cols; j++)
      {
        float val = gradient.values[i][j];
        gradient.values[i][j] = dsigmoid(val);
      }
    }



    gradient.multiply(outputErrors);  //elementWise
    gradient.multiply(LearningRate);  //Scalar

    Matrix hiddenT = Matrix.transpose(hidden);
    Matrix DHOWeights = Matrix.Product(gradient, hiddenT);

    HOWeights.add(DHOWeights);

    Obias.add(gradient);

    Matrix HOWeightsT = Matrix.transpose(HOWeights);
    Matrix hiddenErrors = Matrix.Product(HOWeightsT, outputErrors);

    //java version of matrix map function
    Matrix hiddenGradient = hidden.copy();
    for (int i = 0; i < hiddenGradient.rows; i++)
    {
      for (int j = 0; j < hiddenGradient.cols; j++)
      {
        float val = hiddenGradient.values[i][j];
        hiddenGradient.values[i][j] = dsigmoid(val);
      }
    }

    hiddenGradient.multiply(hiddenErrors);
    hiddenGradient.multiply(LearningRate);

    Matrix inputT = Matrix.transpose(input);
    Matrix DIHWeights = Matrix.Product(hiddenGradient, inputT);

    IHWeights.add(DIHWeights);

    Hbias.add(hiddenGradient);

    //Print(outputs, "outputs");
    //Print(targets, "targets");
    //Print(error, "error");
  }
}
